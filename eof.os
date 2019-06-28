!
!  SCAM/EOF. Operations on ends of files.
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

!  EOF. Represent the end of a file. EOFs are distinct from every other object,
!  and therefore can be used as a sentinels.

  inj eofTag :− makeTag()

  eof :− disp((tuple))

!  MAKE EOF. Return a new EOF.

  makeEof :−
   (proc () ref object:
    (in deferred(interrupt)
     do fromDump(eof, 0, eofTag){ref object}))
)
