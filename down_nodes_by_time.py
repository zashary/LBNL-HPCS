#!/usr/bin/env python
#By: Zashary Maskus-Lavin
#Date: December 2017
import shlex
import subprocess
import sys
import time
import smtplib
from email.mime.text import MIMEText

def send_email(author, to, subject, body):
   msg = MIMEText(body)
   msg['Subject'] = subject
   msg['From'] = author
   msg['To'] = ', '.join(to)
   s = smtplib.SMTP('localhost')
   s.sendmail(author, to, msg.as_string())
   s.quit()
#Finds nodes that have gone down within a day in Unix time.
def downNodes(data):
   body = "Nodes that have gone down within the past day:\n"
   for line in data:
      if (time.mktime(time.localtime()) - line["ts"]) <= 86400:
         body = body + line["original"] + "\n"

#Finds nodes that have gone down within a week in Unix time.
   body = body + "\nNodes that have gone down within the past week:\n"
   for line in data:
      if ((time.mktime(time.localtime()) - line["ts"]) <= 518400) and (time.mktime(time.localtime()) - line["ts"] > 86400):
         body = body + line["original"] + "\n"
def parse(command):
   lines = command.split('\n')
   data = []
   
   offsets = {"reason": lines[0].find("USER"),
              "user":   lines[0].find("TIMESTAMP"),
              "ts":     lines[0].find("NODELIST")}

   #delete header
   del(lines[0])

   for line in lines:
      if line.strip() == '':
         continue
      reason = line[0:offsets["reason"]].strip()
      user = line[offsets["reason"]:offsets["user"]].strip()
      ts = line[offsets["user"]:offsets["ts"]].strip()
      nodes = line[offsets["ts"]:-1].strip()

      try:
         ts2 = time.mktime(time.strptime(ts, "%Y-%m-%dT%H:%M:%S"))
      except:
         print line
         raise

      data.append({"original": line, "reason": reason, "user": user, "ts": ts2, "nodes": nodes})

   return data
#def percentageDown(data,):
   
def getOutput(raw_cmd):
   cmd = shlex.split(raw_cmd)
   #using popen instead of check_command for compatibility reasons
   sinfo_command = subprocess.Popen(cmd, stdout=subprocess.PIPE,stderr=subprocess.PIPE)
   return sinfo_command.communicate()

def main():
   stdout,stderr = getOutput('sinfo -R')
   data = parse(stdout)
   downNodes(data)
if __name__ == '__main__':
	main()
