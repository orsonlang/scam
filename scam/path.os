!
!  SCAM/PATH. Operations on pathnames.
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

!  PATH. An object that stands for a pathname CHARS. PATHs form the nodes of an
!  unbalanced binary search tree, ordered by CHARS slots and linked by LEFT and
!  RIGHT slots.

  path :−
   (tuple
     string       chars,
     var ref path left,
     var ref path right)

!  MAKE PATH. Make a new PATH and return it.

  makePath :−
   (proc (string chars) ref path:
    (with ref var path newPath :− fromHeap(var path)
     do newPath↑.chars := copy(chars)
        newPath↑.left  := nil
        newPath↑.right := nil
        newPath{ref path}))

!  IS INCLUDED. Test if the pathname CHARS appears in the search tree rooted at
!  PATHS, meaning that it has already appeared as an argument to INCLUDE. If it
!  has, then return TRUE. If it hasn't, then add it to PATHS, and return FALSE.

  var ref path paths :− makePath(ϵ)

  isIncluded :−
   (proc (string chars) bool:
    (with
      var int      state   :− 0
      var ref path subtree :− paths
     do (while state = 0
         do (with inj test :− comp(chars, subtree↑.chars)
             do (if test < 0
                 then (if subtree↑.left = nil
                       then subtree↑.left := makePath(chars)
                            state := 1
                       else subtree := subtree↑.left)
                 else if test > 0
                      then (if subtree↑.right = nil
                            then subtree↑.right := makePath(chars)
                                 state := 1
                            else subtree := subtree↑.right)
                      else state := 2)))
        state = 2))
)
