!
!  SCAM/LAMBDA. Operations on lambdas.
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

!  LAMBDA. Represent a user-defined function. LAYER is the current layer at the
!  time it was created. NAMES is a list of its parameter names. TERMS is a list
!  of terms that make up its body, as if they were arguments to LAST.

  inj lambdaTag :− makeTag()

  lambda :−
   disp(
    (tuple
      var ref object layer,
      var ref object names,
      var ref object terms))

!  MAKE LAMBDA. Return a new LAMBDA that contains the parts described above.

  makeLambda :−
   (proc (ref object layer, ref object names, ref object terms) ref object:
    (in deferred(interrupt)
     do (with self :− fromDump(lambda, 3, lambdaTag)
         do self↑.layer := layer
            self↑.names := names
            self↑.terms := terms
            self{ref object})))
)
