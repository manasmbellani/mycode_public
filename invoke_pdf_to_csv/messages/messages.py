#!/usr/bin/env python3

def verbose(msg):
    """Print verbose message

    Args:
        msg (str): message to print
    """
    print("[*] " + msg)

def error(msg):
    """Print error message

    Args:
        msg (str): message to print
    """
    print("[0] " + msg)

def info(msg):
    """Print info message

    Args:
        msg (str): message to print
    """
    print("[+] " + msg)