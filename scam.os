!
!  SCAM. An interpreter for a Scheme-like language.
!
!  Copyright © 2012 James B. Moen.
!
!  This  program is free  software: you  can redistribute  it and/or  modify it
!  under the terms  of the GNU General Public License as  published by the Free
!  Software Foundation,  either version 3 of  the License, or  (at your option)
!  any later version.
!
!  This program is distributed in the  hope that it will be useful, but WITHOUT
!  ANY  WARRANTY;  without even  the  implied  warranty  of MERCHANTABILITY  or
!  FITNESS FOR  A PARTICULAR PURPOSE.  See  the GNU General  Public License for
!  more details.
!
!  You should have received a copy of the GNU General Public License along with
!  this program.  If not, see <http://www.gnu.org/licenses/>.
!

!  SCAM is an interpreter for a functional language which resembles a subset of
!  Scheme. Variables are lexically scoped and functions are tail recursive. The
!  language supports CONSes, NAMEs (symbols), HOOKs (system functions), LAMBDAs
!  (user functions), LISTs (built from CONSes), INTEGERs, and TEXTs (strings).
!
!  We wrote Scam to test the prototype Orson compiler, and specifically to test
!  the Orson library's garbage collector. It's also been used successfully as a
!  language for making PostScript files and parts of web pages.

(load ''lib.ascii'')       !  Operations on ASCII characters.
(load ''lib.char'')        !  Operations on characters.
(load ''lib.command'')     !  Process command line arguments.
(load ''lib.convert'')     !  Convert a string to an integer or a real.
(load ''lib.buffer'')      !  Fixed length linear queues.
(load ''lib.dump'')        !  Dynamic memory with garbage collection.
(load ''lib.fail'')        !  Terminate a program with an error message.
(load ''lib.file'')        !  Input and output on file streams.
(load ''lib.path'')        !  Operations on pathnames.
(load ''lib.string'')      !  Operations on strings.
(load ''lib.throw'')       !  Throw exceptions in response to Unix signals.
(load ''lib.time'')        !  Dates and times.

(prog
  void init      :− initDump()  !  Initialize the garbage collector.
  inj  interrupt :− except()    !  Keyboard interrupt (control C).
)

(load ''char'')            !  Operations on characters.
(load ''cons'')            !  Operations on conses.
(load ''eof'')             !  Operations on ends of files.
(load ''layer'')           !  Operations on lists of binder trees.
(load ''hook'')            !  Operations on hooks.
(load ''name'')            !  Operations on names.
(load ''integer'')         !  Operations on integers.
(load ''lambda'')          !  Operations on lambda expressions.
(load ''path'')            !  Operations on pathnames.
(load ''text'')            !  Operations on texts.

(load ''install'')         !  Bind various names to objects.
(load ''write'')           !  Write expressions.
(load ''error'')           !  Evaluation errors.
(load ''read'')            !  Read expressions.
(load ''evaluate'')        !  Evaluate terms.
(load ''main'')            !  Main program.
