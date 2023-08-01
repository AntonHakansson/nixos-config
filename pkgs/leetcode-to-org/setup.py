#!/usr/bin/env python

from distutils.core import setup

setup(name='leetcode-to-org',
      version='1.0',
      description='Convert a leetcode problem to org-mode format.',
      author='AntonHakansson',
      author_email='anton@hakanssn.com',
      scripts = [ 'leetcode-to-org-mode.py' ],
      requires = [ 'requests', 'lxml', 'pypandoc' ],
      )
