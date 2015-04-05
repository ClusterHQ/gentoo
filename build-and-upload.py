#!/usr/bin/env python
print "hello"

# Import smtplib for the actual sending function
import smtplib

# Import the email modules we'll need
from email.mime.text import MIMEText

import yaml
settings = yaml.load(open("settings.yml").read())

# Open a plain text file for reading.  For this example, assume that
# the text file contains only ASCII characters.
# Create a text/plain message
msg = MIMEText("Build results: XXX")

# me == the sender's email address
# you == the recipient's email address
msg['Subject'] = 'coreos build results'
me = settings["email_from"]
msg['From'] = me
you = settings["email_to"]
msg['To'] = you

# Send the message via our own SMTP server, but don't include the
# envelope header.
s = smtplib.SMTP('smtp.gmail.com', 587)
s.starttls()
s.login(settings["gmail_smtp_username"],
        settings["gmail_smtp_password"])
s.sendmail(me, [you], msg.as_string())
s.quit()
