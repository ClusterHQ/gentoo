# Copyright (c) 2007-2009 Roy Marples <roy@marples.name>
# Released under the 2-clause BSD license.

# Allow any sh script to work with einfo functions and friends
# We also provide a few helpful functions for other programs to use

RC_GOT_FUNCTIONS="yes"

eindent()
{
	: $(( EINFO_INDENT = ${EINFO_INDENT:-0} + 2 ))
	[ "$EINFO_INDENT" -gt 40 ] && EINFO_INDENT=40
	export EINFO_INDENT
}

eoutdent()
{
	: $(( EINFO_INDENT = ${EINFO_INDENT:-0} - 2 ))
	[ "$EINFO_INDENT" -lt 0 ] && EINFO_INDENT=0
	return 0
}

yesno()
{
	[ -z "$1" ] && return 1

	case "$1" in
		[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1) return 0;;
		[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0) return 1;;
	esac

	local value=
	eval value=\$${1}
	case "$value" in
		[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1) return 0;;
		[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0) return 1;;
		*) vewarn "\$$1 is not set properly"; return 1;;
	esac
}

rc_runlevel()
{
    rc-status --runlevel
}

_sanitize_path()
{
	local IFS=":" p= path=
	for p in $PATH; do
		case "$p" in
			/home/core/gentoo/usr/lib/einfo/bin|/home/core/gentoo/usr/lib/einfo/sbin);;
			/home/core/gentoo/usr/bin|/home/core/gentoo/usr/sbin|/usr/bin|/usr/sbin);;
			@PKG_PREFIX@/bin|@PKG_PREFIX@/sbin);;
			@LOCAL_PREFIX@/bin|@LOCAL_PREFIX@/sbin);;
			*) path="$path${path:+:}$p";;
		esac
	done
	echo "$path"
}

# Allow our scripts to support zsh
if [ -n "$ZSH_VERSION" ]; then
	emulate sh
	NULLCMD=:
	alias -g '${1+"$@"}'='"$@"'
	setopt NO_GLOB_SUBST
fi

# Add wrappers to PATH
PATH="/home/core/gentoo/usr/lib/einfo/bin:${PATH}" ; export PATH

for arg; do
	case "$arg" in
		--nocolor|--nocolour|-C)
			EINFO_COLOR="NO" ; export EINFO_COLOR
			;;
	esac
done

if [ -t 1 ] && yesno "${EINFO_COLOR:-YES}"; then
	if [ -z "$GOOD" ]; then
		eval $(eval_ecolors)
	fi
else
	# We need to have shell stub functions so our init scripts can remember
	# the last ecmd
	for _e in ebegin eend error errorn einfo einfon ewarn ewarnn ewend \
		vebegin veend veinfo vewarn vewend; do
		eval "$_e() { local _r; command $_e \"\$@\"; _r=\$?; \
		EINFO_LASTCMD=$_e; export EINFO_LASTCMD ; return \$_r; }"
	done
	unset _e
fi
