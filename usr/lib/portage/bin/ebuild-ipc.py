#!/home/core/gentoo/usr/bin/python -b
# Copyright 2010-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#
# This is a helper which ebuild processes can use
# to communicate with portage's main python process.

import logging
import os
import pickle
import platform
import signal
import sys
import time

def debug_signal(signum, frame):
	import pdb
	pdb.set_trace()

if platform.python_implementation() == 'Jython':
	debug_signum = signal.SIGUSR2 # bug #424259
else:
	debug_signum = signal.SIGUSR1

signal.signal(debug_signum, debug_signal)

# Avoid sandbox violations after python upgrade.
pym_path = os.path.join(os.path.dirname(
	os.path.dirname(os.path.realpath(__file__))), "pym")
if os.environ.get("SANDBOX_ON") == "1":
	sandbox_write = os.environ.get("SANDBOX_WRITE", "").split(":")
	if pym_path not in sandbox_write:
		sandbox_write.append(pym_path)
		os.environ["SANDBOX_WRITE"] = \
			":".join(filter(None, sandbox_write))

import portage
portage._internal_caller = True
portage._disable_legacy_globals()

from portage.util._async.ForkProcess import ForkProcess
from portage.util._eventloop.global_event_loop import global_event_loop
from _emerge.PipeReader import PipeReader

class FifoWriter(ForkProcess):

	__slots__ = ('buf', 'fifo',)

	def _run(self):
		# Atomically write the whole buffer into the fifo.
		with open(self.fifo, 'wb', 0) as f:
			f.write(self.buf)
		return os.EX_OK

class EbuildIpc(object):

	# Timeout for each individual communication attempt (we retry
	# as long as the daemon process appears to be alive).
	_COMMUNICATE_RETRY_TIMEOUT_MS = 15000

	def __init__(self):
		self.fifo_dir = os.environ['PORTAGE_BUILDDIR']
		self.ipc_in_fifo = os.path.join(self.fifo_dir, '.ipc_in')
		self.ipc_out_fifo = os.path.join(self.fifo_dir, '.ipc_out')
		self.ipc_lock_file = os.path.join(self.fifo_dir, '.ipc_lock')

	def _daemon_is_alive(self):
		try:
			builddir_lock = portage.locks.lockfile(self.fifo_dir,
				wantnewlockfile=True, flags=os.O_NONBLOCK)
		except portage.exception.TryAgain:
			return True
		else:
			portage.locks.unlockfile(builddir_lock)
			return False

	def communicate(self, args):

		# Make locks quiet since unintended locking messages displayed on
		# stdout could corrupt the intended output of this program.
		portage.locks._quiet = True
		lock_obj = portage.locks.lockfile(self.ipc_lock_file, unlinkfile=True)

		try:
			return self._communicate(args)
		finally:
			portage.locks.unlockfile(lock_obj)

	def _timeout_retry_msg(self, start_time, when):
		time_elapsed = time.time() - start_time
		portage.util.writemsg_level(
			portage.localization._(
			'ebuild-ipc timed out %s after %d seconds,' + \
			' retrying...\n') % (when, time_elapsed),
			level=logging.ERROR, noiselevel=-1)

	def _no_daemon_msg(self):
		portage.util.writemsg_level(
			portage.localization._(
			'ebuild-ipc: daemon process not detected\n'),
			level=logging.ERROR, noiselevel=-1)

	def _run_writer(self, fifo_writer, msg):
		"""
		Wait on pid and return an appropriate exit code. This
		may return unsuccessfully due to timeout if the daemon
		process does not appear to be alive.
		"""

		start_time = time.time()

		fifo_writer.start()
		eof = fifo_writer.poll() is not None

		while not eof:
			fifo_writer._wait_loop(timeout=self._COMMUNICATE_RETRY_TIMEOUT_MS)

			eof = fifo_writer.poll() is not None
			if eof:
				break
			elif self._daemon_is_alive():
				self._timeout_retry_msg(start_time, msg)
			else:
				fifo_writer.cancel()
				self._no_daemon_msg()
				fifo_writer.wait()
				return 2

		return fifo_writer.wait()

	def _receive_reply(self, input_fd):

		start_time = time.time()

		pipe_reader = PipeReader(input_files={"input_fd":input_fd},
			scheduler=global_event_loop())
		pipe_reader.start()

		eof = pipe_reader.poll() is not None

		while not eof:
			pipe_reader._wait_loop(timeout=self._COMMUNICATE_RETRY_TIMEOUT_MS)
			eof = pipe_reader.poll() is not None
			if not eof:
				if self._daemon_is_alive():
					self._timeout_retry_msg(start_time,
						portage.localization._('during read'))
				else:
					pipe_reader.cancel()
					self._no_daemon_msg()
					return 2

		buf = pipe_reader.getvalue()

		retval = 2

		if not buf:

			portage.util.writemsg_level(
				"ebuild-ipc: %s\n" % \
				(portage.localization._('read failed'),),
				level=logging.ERROR, noiselevel=-1)

		else:

			try:
				reply = pickle.loads(buf)
			except SystemExit:
				raise
			except Exception as e:
				# The pickle module can raise practically
				# any exception when given corrupt data.
				portage.util.writemsg_level(
					"ebuild-ipc: %s\n" % (e,),
					level=logging.ERROR, noiselevel=-1)

			else:

				(out, err, retval) = reply

				if out:
					portage.util.writemsg_stdout(out, noiselevel=-1)

				if err:
					portage.util.writemsg(err, noiselevel=-1)

		return retval

	def _communicate(self, args):

		if not self._daemon_is_alive():
			self._no_daemon_msg()
			return 2

		# Open the input fifo before the output fifo, in order to make it
		# possible for the daemon to send a reply without blocking. This
		# improves performance, and also makes it possible for the daemon
		# to do a non-blocking write without a race condition.
		input_fd = os.open(self.ipc_out_fifo,
			os.O_RDONLY|os.O_NONBLOCK)

		# Use forks so that the child process can handle blocking IO
		# un-interrupted, while the parent handles all timeout
		# considerations. This helps to avoid possible race conditions
		# from interference between timeouts and blocking IO operations.
		msg = portage.localization._('during write')
		retval = self._run_writer(FifoWriter(buf=pickle.dumps(args),
			fifo=self.ipc_in_fifo, scheduler=global_event_loop()), msg)

		if retval != os.EX_OK:
			portage.util.writemsg_level(
				"ebuild-ipc: %s: %s\n" % (msg,
				portage.localization._('subprocess failure: %s') % \
				retval), level=logging.ERROR, noiselevel=-1)
			return retval

		if not self._daemon_is_alive():
			self._no_daemon_msg()
			return 2

		return self._receive_reply(input_fd)

def ebuild_ipc_main(args):
	ebuild_ipc = EbuildIpc()
	return ebuild_ipc.communicate(args)

if __name__ == '__main__':
	sys.exit(ebuild_ipc_main(sys.argv[1:]))
