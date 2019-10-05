!
!  SCAM/MAIN. Main program.
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

(prog

!  MAIN. Main program.

  main :−
   (with
     var bool       batch :− false  !  Are we in batch mode?
     var ref object term  :− nil    !  Object read from an input file.
     var bool       who   :− false  !  Did the user ask who we are?

!  Process command line arguments.

    do (for char option, string value in command(''bv'', '' '')
        do (case option
            of 'b': batch := true
               'v': who := true
               ' ': evaluateFile(value, layers)))

!  Did the user ask who we are?

       (if who
        then writeln(''Scam, version 0.4.''))

!  If we're interactive, then repeatedly read TERM from INPUT, evaluate it, and
!  write the result back to OUTPUT. Continue until we encounter an EOF, or QUIT
!  is called. A keyboard interrupt throws INTERRUPT, which is caught here.

       (if ¬ batch
        then (in blocked(interrupt)
              do (while true
                  do (in immediate(interrupt)
                      do (catch
                           writeln()
                           write(''Q: '')
                           term := readObject(input, ϵ)
                           (if term↑.tag = eofTag
                            then writeln()
                                 exit(0)
                            else term := evaluate(term, layers)
                                 writeln()
                                 write(''A: '')
                                 writeObject(term)
                                 writeln())))))))
)
