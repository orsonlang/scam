!
!  SCAM/NAME. Operations on names.
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

!  NAME. An object that stands for a string CHARS. NAMEs are kept in a bucketed
!  hash table. Every bucket in the table is an unbalanced binary search tree of
!  NAMEs, ordered by their CHARS slots, linked via their LEFT and RIGHT slots.

  inj nameTag :− makeTag()

  name :−
   disp(
    (tuple
      var string   chars,
      var ref name left,
      var ref name right))

!  HASH. Return the hash code of a NAME with a given CHARS slot.

  hash :−
   (form (string chars) int:
    (with
      var int    bits  :− 0
      var string chars :− (past chars)
     do (while chars↑
         do bits := (bits ← 1) ~ chars↑
            chars += 1)
        high(int) & bits))

!  BUCKETS. The hash table. Its length must be a "large" prime number.

  inj bucketsLength :− 997

  buckets :−
   (with var [bucketsLength] var ref name self
    do (for int index in bucketsLength
        do self[index] := nil)
       self)

!  MAKE NAME. Return a NAME whose CHARS slot is CHARS. If such a name exists in
!  the hash table BUCKETS, then return that name. Otherwise we make a new NAME,
!  add it to BUCKETS, and return it. NAMEs are allocated from the heap, not the
!  dump, so they're not subject to garbage collection.

  makeName :−
   (proc (string chars) ref object:
    (with
      int          index   :− hash(chars) mod bucketsLength
      var ref name self    :− nil
      var ref name subtree :− buckets[index]

!  MAKING NAME. Make a new NAME and return it. If the new NAME's CHARS slot has
!  the form "cXr" where X is zero or more "a"s and "d"s, then we make a new CXR
!  hook and bind the new NAME to that hook in the TOP LAYER. This makes it look
!  like all "cXr" functions are defined. We use a little STATE machine to parse
!  the CHARS slots as we build them.

      makingName :−
       (proc () ref name:
        (with
          var row var char0 newChars :− fromHeap(length(chars) + 1, var char0)
          ref name          newName  :− fromHeap(name, 0, nameTag)
          var string        oldChars :− chars
          var int           state    :− 0
         do newName↑.chars := newChars{string}
            (while oldChars↑
             do (case state
                 of 0: (case oldChars↑
                        of 'c': state := 1
                          none: state := 3)
                    1: (case oldChars↑
                        of 'a': state := 1
                           'd': state := 1
                           'r': state := 2
                          none: state := 3)
                    2: state := 3)
                newChars↑ := oldChars↑
                newChars += 1
                oldChars += 1)
            newChars↑ := '\0'
            (if state = 2
             then setKey(
                   topLayer,
                   newName{ref object},
                   makeHook(newName↑.chars, cxrCode)))
            newName))

!  This is MAKE NAME's body. Search SUBTREE for a NAME with a CHARS slot that's
!  equal to CHARS. If we find one, then return it. Otherwise make a new one and
!  add it to SUBTREE as a leaf.

     do (in deferred(interrupt)
         do (if subtree = nil
             then self := makingName()
                  buckets[index] := self
             else (while
                   (if chars < subtree↑.chars
                    then (if subtree↑.left = nil
                          then self := makingName()
                               subtree↑.left := self
                               false
                          else subtree := subtree↑.left
                               true)
                    else if chars > subtree↑.chars
                         then (if subtree↑.right = nil
                               then self := makingName()
                                    subtree↑.right := self
                                    false
                               else subtree := subtree↑.right
                                    true)
                         else self := subtree
                              false)))
            self{ref object})))
)
