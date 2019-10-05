!
!  SCAM/ERROR. Evaluation errors.
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
  inj "scam error" :− except()

!  ERROR. Assert that an error has occurred. Write either MESSAGE, or a list of
!  OBJECTS formatted by MESSAGE, or part of a TERM followed by MESSAGE. Then in
!  all cases, THROW an exception to escape from whatever we're doing.

  error :−
   (alt
    (form (string message) void:
      unattributedError(message)
      throw("scam error")),
    (form (string message, list objects) void:
      writeln()
      writeln(message & '.', objects)
      throw("scam error")),
    (form (ref object term, string message) void:
      attributedError(term, message)
      throw("scam error")))

!  ATTRIBUTED ERROR. Write either TERM or its CAR, followed by MESSAGE.

  attributedError :−
   (proc (ref object term, string message) void:
     writeln()
     (if term = nil ∨ term↑.tag ≠ consTag
      then writeObject(term)
      else writeObject(term↑.car))
     write('': '')
     write(message)
     writeln('.'))

!  UNATTRIBUTED ERROR. Write just MESSAGE.

  unattributedError :−
   (proc (string message) void:
     writeln()
     write(message)
     writeln('.'))
)
