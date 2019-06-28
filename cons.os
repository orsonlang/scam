!
!  SCAM/CONS. Operations on conses.
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

!  OBJECT. An OBJECT is really a CONS, but we call it an OBJECT because most of
!  the things we work with are CONSes. Each CONS has two pointer slots, CAR and
!  CDR. MARKED TAG indicates a previously visited CONS (see SCAM/WRITE).

  inj consTag   :− makeTag()
  inj markedTag :− makeTag()

  object :−
   disp(
    (tuple
      var ref object car,
      var ref object cdr))

!  MAKE CONS. Return a CONS whose CAR slot is CAR, and whose CDR slot is CDR.

  makeCons :−
   (proc (ref object car, ref object cdr) ref object:
    (in deferred(interrupt)
     do (with self :− fromDump(object, 2, consTag)
         do self↑.car := car
            self↑.cdr := cdr
            self)))
)
