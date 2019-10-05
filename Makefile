#
#	 SCAM/MAKEFILE. Compile, install, uninstall Scam.
#
#	 Copyright © 2019 James B. Moen and Jade Michael Thornton.
#	 Copyright © 2013 James B. Moen.
#
#	 This	 program is free	software: you	 can redistribute	 it and/or	modify it
#	 under the terms	of the GNU General Public License as	published by the Free
#	 Software Foundation,	 either version 3 of	the License, or	 (at your option)
#	 any later version.
#
#	 This program is distributed in the	 hope that it will be useful, but WITHOUT
#	 ANY	WARRANTY;	 without even	 the	implied	 warranty	 of MERCHANTABILITY	 or
#	 FITNESS FOR	A PARTICULAR PURPOSE.	 See	the GNU General	 Public License for
#	 more details.
#
#	 You should have received a copy of the GNU General Public License along with
#	 this program.	If not, see <http://www.gnu.org/licenses/>.
#

#	 Each action has a comment that describes exactly what it does to your system
#	 and whether you must be root to do it. Please read these comments carefully!
#	 This Makefile assumes that an Orson compiler is installed. An Orson compiler
#	 is available for free from the author.
#
#	 The following directories are where Scam will be installed.
#
#		 PREFIX/BINDIR	 Scam will be installed here.
#		 PREFIX/MANDIR	 The Scam "man" page will be installed here.
#
#	 If these directories do not exist, then they will be created.

prefix = /usr/local
bindir = $(prefix)/bin
mandir = $(prefix)/man/man1

#	 ALL. Compile Scam, leaving it in the current directory. You need not be root
#	 to do this.

all:
	cd scam; \
	orson scam.os; \
	mv a.out ../scam

#	 CLEAN. Undo MAKE ALL. You need not be root to do this.

clean:
	rm -f Out.c a.out scam

#	 INSTALL. Install Scam, by doing these things.
#
#		 1. Make BIN DIRECTORY if it doesn't exist.
#		 2. Make MAN DIRECTORY if it doesn't exist.
#		 3. Compile Scam.
#		 4. Move Scam to BIN DIRECTORY.
#		 5. Make root the owner of Scam.
#		 6. Let nonroots read and run Scam, but not write it.
#		 7. Copy the Scam man page to MAN DIRECTORY.
#		 8. Make root the owner of the Scam man page.
#		 9. Let nonroots read the Scam man page, but not run or write it.

install:
	mkdir -p $(bindir)
	mkdir -p $(mandir)
	cd scam; \
	orson scam.os; \
	mv a.out $(bindir)/scam
	chown root $(bindir)/scam
	chmod go-w+rx $(bindir)/scam
	cp doc/scam.1 $(mandir)/
	chown root $(mandir)/scam.1
	chmod go-wx+r $(mandir)/scam.1

#	 UNINSTALL. Undo the effects of MAKE INSTALL, by doing these things.
#
#		 1. Undo the effects of MAKE ALL.
#		 2. Delete Scam from BIN DIRECTORY.
#		 3. Delete the Scam man page from MAN DIRECTORY.
#
#	 Note that BIN DIRECTORY and MAN DIRECTORY will still exist. You must be root
#	 to do this.

uninstall:
	rm -f Out.c a.out scam
	rm -f $(bindir)/scam
	rm -f $(mandir)/scam.1
