!
!  SCAM/LAYER. Operations on lists of binder trees.
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

!  BINDER. Assert that the name KEY has been bound to the object VALUE. BINDERs
!  are organized into AVL trees. They're ordered by the addresses of KEY slots,
!  and linked through their LEFT and RIGHT slots. They must be AVL trees, since
!  KEYs may arrive in order of their addresses.  Balance information is held in
!  TAG slots using EVEN BINDER, LEFT BINDER, and RIGHT BINDER tags.

  inj evenBinderTag  :− makeTag()
  inj leftBinderTag  :− makeTag()
  inj rightBinderTag :− makeTag()

  binder :−
   disp(
    (tuple
      var ref object key,
      var ref object value,
      var ref binder left,
      var ref binder right))

!  MAKE BINDER. Return a new binder whose KEY slot is KEY, and whose VALUE slot
!  is VALUE.

  makeBinder :−
   (proc (ref object key, ref object value) ref binder:
    (in deferred(interrupt)
     do (with ref binder self :− fromDump(binder, 4, evenBinderTag)
         do self↑.key   := key
            self↑.value := value
            self)))

!  MAKE LAYER. Return a new layer with a new empty AVL tree as its CAR.

  makeLayer :−
   (form (ref object layer) ref object:
     makeCons(nil, layer))

!  LAYERS is a chain of CONSes linked through their CDRs. Each CAR holds an AVL
!  tree made from BINDERs. The first tree in the chain contains bindings of the
!  names in the topmost lexical scope. When we enter a new scope, we push a new
!  AVL tree on top of LAYERS. When we exit the scope, we discard that AVL tree,
!  but we don't explicitly destroy it, because a lambda closure might reference
!  it. If it's no longer needed, then the garbage collector will destroy it.

  var ref object layers   :− makeLayer(nil)
  ref object     topLayer :− layers

!  GOT KEY. Test if the name KEY is bound to an object in LAYER. If it is, then
!  set VALUE to that object, and return TRUE. If it's not, then repeat with the
!  layer below LAYER. If we run out of layers, then set VALUE to NIL and return
!  FALSE.

  gotKey :−
   (proc (var ref object value, ref object layer, ref object key) bool:
    (with
      var bool       found :− false
      var ref object layer :− (past layer)
     do value := nil
        (while ¬ found ∧ layer ≠ nil
         do (with var ref binder temp :− layer↑.car{ref binder}
             do (while ¬ found ∧ temp ≠ nil
                 do (if key < temp↑.key
                     then temp := temp↑.left
                     else if key > temp↑.key
                          then temp := temp↑.right
                          else found := true
                               value := temp↑.value))
                layer := layer↑.cdr))
        found))

!  RESET KEY. Test if a name KEY is bound to an object in LAYER. If it is, then
!  set its binding to VALUE, and return TRUE. If it's not, then repeat with the
!  layer below LAYER. If we run out of layers, then return FALSE.

  resetKey :−
   (proc (ref object layer, ref object key, ref object value) bool:
    (with
      var bool       found :− false
      var ref object layer :− (past layer)
     do (while ¬ found ∧ layer ≠ nil
         do (with var ref binder temp :− layer↑.car{ref binder}
             do (while ¬ found ∧ temp ≠ nil
                 do (if key < temp↑.key
                     then temp := temp↑.left
                     else if key > temp↑.key
                          then temp := temp↑.right
                          else found := true
                               temp↑.value := value))
                layer := layer↑.cdr))
        found))

!  SET KEY. Modify the first AVL tree in LAYER so that the name KEY is bound to
!  VALUE. We may add a new BINDER to the tree or modify one that now exists.

  setKey :−
   (proc (ref object layer, ref object key, ref object value) void:
    (with
      var bool       higher :− false
      var ref binder p₁     :− nil
      var ref binder p₂     :− nil

!  SETTING KEY. A recursive AVL algorithm which searches the tree P₀ on its way
!  down and rebalances P₀ on its way back up. HIGHER tells when one side of the
!  tree is too much deeper than the other. See:
!
!  Niklaus Wirth.  Algorithms + Data Structures = Programs. Prentice-Hall, Inc.
!  Englewood Cliffs, New Jersey. 1976. pp. 216–222.
!
!  If P₀ is NIL, then no BINDER contains KEY. Add a new BINDER to the tree, and
!  assert HIGHER to begin rebalancing.

      settingKey :−
       (proc (ref binder p₀) ref binder:
        (with var ref binder p₀ :− (past p₀)
         do (if p₀ = nil
             then higher := true
                  makeBinder(key, value)
             else

!  Test if KEY is in P₀'s left subtree. Rebalance if necessary.

             if key < p₀↑.key
             then p₀↑.left := settingKey(p₀↑.left)
                  (if higher
                   then (case p₀↑.tag
                         of leftBinderTag:
                             (p₁ := p₀↑.left
                              (if p₁↑.tag = leftBinderTag
                               then p₀↑.left := p₁↑.right
                                    p₁↑.right := p₀
                                    p₀↑.tag := evenBinderTag
                                    p₀ := p₁
                               else p₂ := p₁↑.right
                                    p₁↑.right := p₂↑.left
                                    p₂↑.left := p₁
                                    p₀↑.left := p₂↑.right
                                    p₂↑.right := p₀
                                    (if p₂↑.tag = leftBinderTag
                                     then p₀↑.tag := rightBinderTag
                                     else p₀↑.tag := evenBinderTag)
                                    (if p₂↑.tag = rightBinderTag
                                     then p₁↑.tag := leftBinderTag
                                     else p₁↑.tag := evenBinderTag)
                                    p₀ := p₂)
                              higher := false
                              p₀↑.tag := evenBinderTag
                              p₀)
                            evenBinderTag:
                             (p₀↑.tag := leftBinderTag
                              p₀)
                            rightBinderTag:
                             (higher := false
                              p₀↑.tag := evenBinderTag
                              p₀)
                            none:
                             fail(''Bad tag in settingKey!''))
                   else p₀)
             else

!  Test if KEY is in P₀'s right subtree. Rebalance if necessary.

             if key > p₀↑.key
             then p₀↑.right := settingKey(p₀↑.right)
                  (if higher
                   then (case p₀↑.tag
                         of leftBinderTag:
                             (higher := false
                              p₀↑.tag := evenBinderTag
                              p₀)
                            evenBinderTag:
                             (p₀↑.tag := rightBinderTag
                              p₀)
                            rightBinderTag:
                             (p₁ := p₀↑.right
                              (if p₁↑.tag = rightBinderTag
                               then p₀↑.right := p₁↑.left
                                    p₁↑.left := p₀
                                    p₀↑.tag := evenBinderTag
                                    p₀ := p₁
                               else p₂ := p₁↑.left
                                    p₁↑.left := p₂↑.right
                                    p₂↑.right := p₁
                                    p₀↑.right := p₂↑.left
                                    p₂↑.left := p₀
                                    (if p₂↑.tag = rightBinderTag
                                     then p₀↑.tag := leftBinderTag
                                     else p₀↑.tag := evenBinderTag)
                                    (if p₂↑.tag = leftBinderTag
                                     then p₁↑.tag := rightBinderTag
                                     else p₁↑.tag := evenBinderTag)
                                    p₀ := p₂)
                              higher := false
                              p₀↑.tag := evenBinderTag
                              p₀)
                            none:
                             fail(''Bad tag in settingKey!''))
                   else p₀)

!  If it's not in either subtree, then it must be in P₀. Reset its VALUE slot.

             else higher := false
                  p₀↑.value := value
                  p₀)))

!  This is SET KEY's body. If LAYER is not NIL, then call SETTING KEY to do all
!  the work.

     do (if layer = nil
         then fail(''No layer in setKey!'')
         else layer↑.car := settingKey(layer↑.car{ref binder}){ref object})))
)
