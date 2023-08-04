#!/usr/bin/env python

import wexpect
import time
import sys
from subprocess import Popen
from optparse import OptionParser


def add_options(parser):
    parser.add_option(
        "-i",
        "--bf2-ip",
        action="store",
        help=
        "management IP of the BlueField-2 card",
        dest="bf2_ip")


if __name__ == '__main__':
    parser = OptionParser()
    add_options(parser)
    (options, args) = parser.parse_args()

#login for the first time after OS installition    
    print(args[0]) #bluefield ip
    print(args[1]) #bluefield username password
    print(args[2]) #bluefield root password    
    p = wexpect.spawn('plink.exe ubuntu@'+args[0])
    #p.expect('info)')
    p.expect('password:')
    p.sendline('y')
    p.sendline('\n')
    p.expect('password:')
    p.sendline('ubuntu')    
    p.expect('session.')
    p.sendline('\n')
    p.expect('password:')
    p.sendline('ubuntu')
    p.expect("New password:")
    p.sendline(args[1])
    p.expect("Retype new password:")
    p.sendline(args[1])
    
#login for the second time:
    p = wexpect.spawn('plink.exe ubuntu@'+args[0])
    p.expect('password:')
    p.sendline(args[1])
    p.expect('session.')
    p.sendline('\n')
    p.expect('$', timeout=20)  
# changing the root password 
    p.sendline("sudo -i")
    p.sendline("passwd root")
    p.expect("New password:")
    p.sendline(args[2])
    p.expect("Retype new password:")
    p.sendline(args[2])
# root password successfully changed!

# changing the ubuntu password     
    p.sendline("passwd ubuntu")
    p.expect("New password:")
    p.sendline(args[1])
    p.expect("Retype new password:")
    p.sendline(args[1])
# ubuntu password successfully changed!

    p.sendline("exit")
    p.expect(r'ubuntu@.*\$')
    print("Password changed!!")
    p.sendline("exit")
