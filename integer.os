!
!  SCAM/INTEGER. Operations on integers.
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

!  INTEGER. Represent the integer SELF.

  inj integerTag :− makeTag()

  integer :− disp((tuple var int self))

!  MAKE INTEGER. Return a new INTEGER that represents the integer SELF.

  makeInteger :−
   (proc (int self) ref object:
    (in deferred(interrupt)
     do (with ref integer temp :− fromDump(integer, 0, integerTag)
         do temp↑.self := self
            temp{ref object})))
)
