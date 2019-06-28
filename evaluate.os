!
!  SCAM/EVALUATE. Evaluate terms.
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
  inj            exception  :− except()  !  CATCH terminated by Scam THROW.
  inj            normal     :− 0         !  CATCH terminated normally.
  string         scamSuffix :− ''scam''  !  Suffix for Scam Source files.
  var ref object thrown     :− nil       !  The object thrown by THROW.

!  BOOLIFY. Convert an Orson Boolean to a Scam Boolean.

  boolify :−
   (form (bool test) ref object:
    (if test
     then trueName
     else nilName))

!  EVALUATE. Evaluate TERM in the environment LAYERS, and return its value.

  evaluate :−
   (proc (ref object term, ref object layers) ref object:
    (with
      var bool       going
      var ref object layers :− (past layers)
      var ref object term   :− (past term)
      var ref object value  :− nil

!  AT END. If OBJECTS is a CONS, then return TRUE. If OBJECTS is NIL NAME, then
!  return FALSE. Otherwise assert an error.

      atEnd :−
       (proc (ref object objects) bool:
        (if objects↑.tag = consTag
         then false
         else if objects = nilName
              then true
              else error(term, ''Proper list expected'')))

!  EVALUATE. Do an ordinary recursion. If LAYERS is missing, it defaults to the
!  current LAYERS.

      evaluate :−
       (alt
        (form (ref object term) ref object:
         (past evaluate)(term, layers)),
        (form (ref object term, ref object layers) ref object:
         (past evaluate)(term, layers)))

!  RECURSE. Do a tail recursion with TERM' in place of TERM and optionally with
!  LAYERS' in place of LAYERS.

      recurse :−
       (alt
        (form (ref object term') void:
          going := true
          term  := term'),
        (form (ref object term', ref object layers') void:
          going := true
          term := term'
          layers := layers'))

!  RETURN. Return VALUE' from the current evaluation.

      return :−
       (form (ref object value') void:
         value := value')

!  CONS AND OBJECT. Wrapper. Call BODY on two arguments from TERM. The first of
!  them must be a CONS. The second may be any object.

      consAndObject :−
       (form (ref object term) foj:
        (form (form (ref object, ref object) obj body) void:
         (with
           var ref object left  :− nil
           var ref object right :− nil
           var ref object terms :− term↑.cdr
          do (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else left := terms↑.car
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else right := terms↑.car
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then left := evaluate(left)
                   right := evaluate(right)
                   (if left↑.tag = consTag
                    then body(left, right)
                    else error(''Cons expected''))
              else error(term, ''Too many arguments'')))))

!  ONE OBJECT. Wrapper. Call BODY on one argument from TERM. It may be any kind
!  of object.

      oneObject :−
       (form (ref object term) foj:
        (form (form (ref object) obj body) void:
         (with
           var ref object arg   :− nil
           ref object     terms :− term↑.cdr
           do (if atEnd(terms)
               then error(term, ''Not enough arguments'')
               else arg := evaluate(terms↑.car)
                    (if atEnd(terms↑.cdr)
                     then body(arg)
                     else error(term, ''Too many arguments''))))))

!  ONE TEXT. Wrapper. Call BODY on one argument from TERM. It must be a TEXT.

      oneText :−
       (form (ref object term) foj:
        (form (form (ref text) obj body) void:
         (with
           var ref object arg   :− nil
           var ref object terms :− term↑.cdr
          do (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else arg := evaluate(terms↑.car)
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then (if arg↑.tag = textTag
                    then body(arg{ref text})
                    else error(''String expected''))
              else error(''Too many arguments'')))))

!  NAME AND OBJECT. Wrapper. Call BODY on two arguments from TERM: a NAME which
!  is not evaluated, and an evaluated object.

      nameAndObject :−
       (form (ref object term) foj:
        (form (form (ref object, ref object) obj body) void:
         (with
           var ref object terms :− term↑.cdr
           var ref object left  :− nil
           var ref object right :− nil
          do (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else left := terms↑.car
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else right := terms↑.car
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then (if left↑.tag = nameTag
                    then right := evaluate(right)
                         body(left, right)
                    else error(term, ''Name expected''))
              else error(term, ''Too many arguments'')))))

!  TWO INTEGERS. Wrapper. Call BODY on two arguments from TERM, both integers.

      twoIntegers :−
       (form (ref object term) foj:
        (form (form (int, int) obj body) void:
         (with
           var ref object left  :− nil
           var ref object right :− nil
           var ref object terms :− term↑.cdr
          do (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else left := terms↑.car
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else right := terms↑.car
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then left := evaluate(left)
                   right := evaluate(right)
                   (if left↑.tag = integerTag ∧ right↑.tag = integerTag
                    then body(
                          left{ref integer}↑.self,
                          right{ref integer}↑.self)
                    else error(term, ''Integer expected''))
              else error(term, ''Too many arguments'')))))

!  TWO OBJECTS. Wrapper. Call BODY on two arguments from TERM. These may be any
!  objects.

      twoObjects :−
       (form (ref object term) foj:
        (form (form (ref object, ref object) obj body) void:
         (with
           var ref object left  :− nil
           var ref object right :− nil
           var ref object terms :− term↑.cdr
          do (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else left := terms↑.car
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else right := terms↑.car
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then left := evaluate(left)
                   right := evaluate(right)
                   body(left, right)
              else error(term, ''Too many arguments'')))))

!  TWO TEXTS. Wrapper. Call BODY on two arguments from TERM. Both arguments are
!  required to be texts.

      twoTexts :−
       (form (ref object term) foj:
        (form (form (ref text, ref text) obj body) void:
         (with
           var ref object left  :− nil
           var ref object right :− nil
           var ref object terms :− term↑.cdr
          do (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else left := evaluate(terms↑.car)
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then error(term, ''Not enough arguments'')
              else right := evaluate(terms↑.car)
                   terms := terms↑.cdr)
             (if atEnd(terms)
              then (if left↑.tag = textTag ∧ right↑.tag = textTag
                    then body(left{ref text}, right{ref text})
                    else error(term, ''String expected''))
              else error(term, ''Too many arguments'')))))

!  ZERO OR MORE INTEGERS. Iterator. Call BODY on arguments from TERM, which are
!  all integers.

      zeroOrMoreIntegers :−
       (form (ref object term) foj:
        (form (form (int) obj body) void:
         (with
           var ref object arg   :− nil
           var ref object terms :− term↑.cdr
          do (while ¬ atEnd(terms)
              do arg := evaluate(terms↑.car)
                 (if arg↑.tag = integerTag
                  then body(arg{ref integer}↑.self)
                       terms := terms↑.cdr
                  else error(term, ''Integer expected''))))))

!  EVALUATE AND. McCarthy conjunction. Evaluate a series of arguments in order.
!  If one returns NIL NAME, then return NIL NAME without evaluating the others.
!  Otherwise, return the value of the last argument. If there are no arguments,
!  then return TRUE NAME.

      evaluateAnd :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then return(trueName)
             else (while
                   (if atEnd(terms↑.cdr)
                    then recurse(terms↑.car)
                         false
                    else if evaluate(terms↑.car) = nilName
                         then return(nilName)
                              false
                         else terms := terms↑.cdr
                              true)))))

!  EVALUATE CALL. Evaluate a call to a HOOK or a LAMBDA.

      evaluateCall :−
       (form () void:
        (with
          ref object function :− evaluate(term↑.car)

!  EVALUATE LAMBDA. Evaluate a call to a LAMBDA.

          evaluateLambda :−
           (form () void:
            (with
              var ref object args  :− term↑.cdr
              var ref object layer :− makeLayer(function{ref lambda}↑.layer)
              var ref object name  :− nil
              var ref object names :− function{ref lambda}↑.names
              var ref object terms :− function{ref lambda}↑.terms
            do (while ¬ atEnd(args) ∧ ¬ atEnd(names)
                do setKey(layer, names↑.car, evaluate(args↑.car))
                   args := args↑.cdr
                   names := names↑.cdr)
               (if atEnd(args)
                then (if atEnd(names)
                      then (while ¬ atEnd(terms↑.cdr)
                            do evaluate(terms↑.car, layer)
                               terms := terms↑.cdr)
                           recurse(terms↑.car, layer)
                      else error(term, ''Not enough arguments''))
                else error(term, ''Too many arguments''))))

!  This is EVALUATE CALL's body.

         do (if function↑.tag = hookTag
             then (case function{ref hook}↑.code
                   of andCode: evaluateAnd()
                      carCode: evaluateCar()
                    catchCode: evaluateCatch()
                      cdrCode: evaluateCdr()
                     consCode: evaluateCons()
                      cxrCode: evaluateCxr(function)
                   defineCode: evaluateDefine()
                    firstCode: evaluateFirst()
                       ifCode: evaluateIf()
                    implyCode: evaluateImply()
                  includeCode: evaluateInclude()
                   intAddCode: evaluateIntAdd()
                   intAndCode: evaluateIntAnd()
                   intDivCode: evaluateIntDiv()
                    intEqCode: evaluateIntEq()
                    intGeCode: evaluateIntGe()
                    intGtCode: evaluateIntGt()
                    intLeCode: evaluateIntLe()
                    intLtCode: evaluateIntLt()
                   intModCode: evaluateIntMod()
                   intMulCode: evaluateIntMul()
                    intNeCode: evaluateIntNe()
                   intNegCode: evaluateIntNeg()
                   intNotCode: evaluateIntNot()
                    intOrCode: evaluateIntOr()
                   intSubCode: evaluateIntSub()
                   intXorCode: evaluateIntXor()
                   isConsCode: evaluateIsCons()
                   isHookCode: evaluateIsHook()
                    isEofCode: evaluateIsEof()
                    isIntCode: evaluateIsInt()
                 isLambdaCode: evaluateIsLambda()
                   isNameCode: evaluateIsName()
                    isNilCode: evaluateIsNil()
                 isStringCode: evaluateIsString()
                   lambdaCode: evaluateClose()
                     lastCode: evaluateLast()
                      letCode: evaluateLet()
                     listCode: evaluateList()
                     loadCode: evaluateLoad()
                  nameStrCode: evaluateNameStr()
                    objEqCode: evaluateObjEq()
                   objLenCode: evaluateObjLen()
                    objNeCode: evaluateObjNe()
                 objWriteCode: evaluateObjWrite()
                       orCode: evaluateOr()
                     quitCode: evaluateQuit()
                    quoteCode: evaluateQuote()
                      setCode: evaluateSet()
                   strAddCode: evaluateStrAdd()
                   setCarCode: evaluateSetCar()
                   setCdrCode: evaluateSetCdr()
                  strDateCode: evaluateStrDate()
                    strEqCode: evaluateStrEq()
                    strGeCode: evaluateStrGe()
                    strGtCode: evaluateStrGt()
                    strLeCode: evaluateStrLe()
                   strLenCode: evaluateStrLen()
                   strLowCode: evaluateStrLow()
                    strLtCode: evaluateStrLt()
                  strNameCode: evaluateStrName()
                    strNeCode: evaluateStrNe()
                  strReadCode: evaluateStrRead()
                   strSubCode: evaluateStrSub()
                    strUpCode: evaluateStrUp()
                 strWriteCode: evaluateStrWrite()
                    throwCode: evaluateThrow()
                         none: evaluateUnknown())
             else if function↑.tag = lambdaTag
                  then evaluateLambda()
                  else evaluateUnknown())))

!  EVALUATE CAR. Return the CAR of a CONS.

      evaluateCar :−
       (form () void:
        (for ref object arg in oneObject(term)
         do (if arg↑.tag = consTag
             then return(arg↑.car)
             else error(term, ''Cons expected''))))

!  EVALUATE CATCH. Evaluate a series of arguments in order and return the value
!  of the last argument. However, if THROW is evaluated by an argument, then we
!  return the object passed to THROW without evaluating the other arguments. If
!  there are no arguments, then return NIL NAME.

      evaluateCatch :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then return(nilName)
             else (case
                   (catch
                    (while ¬ atEnd(terms↑.cdr)
                     do evaluate(terms↑.car)
                        terms := terms↑.cdr)
                    return(evaluate(terms↑.car)))
                   of normal:    skip
                      exception: return(thrown)
                      none:      rethrow()))))

!  EVALUATE CDR. Return the CDR of a CONS.

      evaluateCdr :−
       (form () void:
        (for ref object arg in oneObject(term)
         do (if arg↑.tag = consTag
             then return(arg↑.cdr)
             else error(term, ''Cons expected''))))

!  EVALUATE CLOSE. Return a lambda closure, given an unevaluated parameter list
!  and an unevaluated body.

      evaluateClose :−
       (form () void:
        (with
          var ref object names :− nil
          var ref object terms :− term↑.cdr

!  CHECK PARAMETER LIST. If NAMES isn't a proper list of zero or more names, in
!  which no name appears more than once, then issue an ERROR.

          checkParameterList :−
           (form (ref object names) void:
            (with
              var ref object name       :− nil
              var ref object names      :− (past names)
              var ref object otherNames :− nil
             do (while ¬ atEnd(names)
                 do name := names↑.car
                    names := names↑.cdr
                    (if name↑.tag = nameTag
                     then otherNames := names
                          (while ¬ atEnd(otherNames)
                           do (if name = otherNames↑.car
                               then error(name, ''Repeated parameter name'')
                               else otherNames := otherNames↑.cdr))
                     else error(term, ''Parameter is not a name'')))))

!  CHECK BODY. If TERMS isn't a proper list, then issue an ERROR.

          checkBody :−
           (form (ref object terms) void:
            (with var ref object terms :− (past terms)
             do (while ¬ atEnd(terms)
                 do terms := terms↑.cdr)))

!  This is EVALUATE CLOSE's body.

         do (if atEnd(terms)
             then error(term, ''Not enough arguments'')
             else names := terms↑.car
                  terms := terms↑.cdr)
            (if atEnd(terms)
             then error(term, ''Not enough arguments'')
             else checkParameterList(names)
                  checkBody(terms)
                  return(makeLambda(layers, names, terms)))))

!  EVALUATE CONS. Return a CONS with a given CAR and CDR.

      evaluateCons :−
       (form () void:
        (for ref object car, ref object cdr in twoObjects(term)
         do return(makeCons(car, cdr))))

!  EVALUATE CXR. Evaluate a composition of CARs and CDRs, as represented in the
!  CHARS slot of FUNCTION.

     evaluateCxr :−
      (form (ref object function) void:
       (for ref object arg in oneObject(term)
        do (with
             var ref object arg   :− (past arg)
             var string     chars :− function{ref hook}↑.chars
            do chars += length(chars) − 2
               (while chars↑ ≠ 'c'
                do (if arg↑.tag = consTag
                    then (if chars↑ = 'a'
                          then arg := arg↑.car
                          else arg := arg↑.cdr)
                         chars −= 1
                    else error(term, ''Cons expected'')))
               return(arg))))

!  EVALUATE DEFINE. Bind an unevaluated NAME to an object in the current LAYER.

      evaluateDefine :−
       (form () void:
        (for ref object left, ref object right in nameAndObject(term)
         do setKey(layers, left, right)
            return(left)))

!  EVALUATE FIRST. Evaluate a series of arguments in order and return the value
!  of the first such argument. If there are no arguments, return NIL NAME.

      evaluateFirst :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then return(nilName)
             else return(evaluate(terms↑.car))
                  (while
                    terms := terms↑.cdr
                    ¬ atEnd(terms)
                   do evaluate(terms↑.car)))))

!  EVALUATE IF. Evaluate an IF THEN ELSE conditional. If there is no ELSE part,
!  then it defaults to NIL NAME.

      evaluateIf :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then error(term, ''Not enough arguments'')
             else if evaluate(terms↑.car) = nilName
                  then terms := terms↑.cdr
                       (if atEnd(terms)
                        then error(term, ''Not enough arguments'')
                        else terms := terms↑.cdr)
                       (if atEnd(terms)
                        then return(nilName)
                        else if atEnd(terms↑.cdr)
                             then recurse(terms↑.car)
                             else error(term, ''Not enough arguments''))
                 else terms := terms↑.cdr
                       (if atEnd(terms)
                        then error(term, ''Not enough arguments'')
                        else if atEnd(terms↑.cdr) ∨ atEnd(terms↑.cdr↑.cdr)
                             then recurse(terms↑.car)
                             else error(term, ''Too many arguments'')))))

!  EVALUATE IMPLY. The following IMPLY:
!
!                          (imply A₁ A₂ ... Aⱼ₋₁ Aⱼ)
!
!  is equivalent to this OR:
!
!                    (or (not A₁) (not A₂) (not Aⱼ₋₁) Aⱼ)

      evaluateImply :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then return(nilName)
             else (while
                   (if atEnd(terms↑.cdr)
                    then recurse(terms↑.car)
                         false
                    else if evaluate(terms↑.car) = nilName
                         then return(trueName)
                              false
                         else terms := terms↑.cdr
                              true)))))

!  EVALUATE INCLUDE. Like EVALUATE LOAD, but load the file only if its pathname
!  has not been previously been loaded by INCLUDE.

      evaluateInclude :−
       (form () void:
        (for ref text arg in oneText(term)
         do (with var buffer(maxLineLength, char0) path
             do empty(path)
                (for char0 ch in elements(arg)
                 do (if isFull(path)
                     then error(term, ''Path string is too long'')
                     else append(path, ch)))
                (if ¬ isIncluded(path{string})
                 then evaluateFile(path{string}, layers))
                return(arg{ref object}))))

!  EVALUATE INT ADD. Add zero or more integers.

      evaluateIntAdd :−
       (form () void:
        (with var int temp :− 0
         do (for int arg in zeroOrMoreIntegers(term)
             do temp += arg)
            return(makeInteger(temp))))

!  EVALUATE INT AND. Conjoin a series of zero or more integers.

      evaluateIntAnd :−
       (form () void:
        (with var int temp :− −1
         do (for int arg in zeroOrMoreIntegers(term)
             do temp &= arg)
            return(makeInteger(temp))))

!  EVALUATE INT DIV. Divide one integer by another. The second must not be 0.

      evaluateIntDiv :−
       (form () void:
        (for int left, int right in twoIntegers(term)
         do (if right = 0
             then error(term, ''Division by zero'')
             else return(makeInteger(left / right)))))

!  EVALUATE INT EQ. Test if two integers are equal.

      evaluateIntEq :−
       (form () void:
        (for int left, int right in twoIntegers(term)
         do return(boolify(left = right))))

!  EVALUATE INT GE. Test if one integer is greater than or equal to another.

      evaluateIntGe :−
       (form () void:
        (for int left, int right in twoIntegers(term)
         do return(boolify(left ≥ right))))

!  EVALUATE INT GT. Test if one integer is greater than another.

      evaluateIntGt :−
       (form () void:
        (for int left, int right in twoIntegers(term)
         do return(boolify(left > right))))

!  EVALUATE INT LE. Test if one integer is less than or equal to another.

      evaluateIntLe :−
       (form () void:
        (for int left, int right in twoIntegers(term)
         do return(boolify(left ≤ right))))

!  EVALUATE INT LT. Test if one integer is less than another.

      evaluateIntLt :−
       (form () void:
        (for int left, int right in twoIntegers(term)
         do return(boolify(left < right))))

!  EVALUATE INT MOD. Return the remainder after dividing an integer by another.
!  The second integer must not be 0.

     evaluateIntMod :−
      (form () void:
       (for int left, int right in twoIntegers(term)
        do (if right = 0
            then error(term, ''division by zero'')
            else return(makeInteger(left mod right)))))

!  EVALUATE INT MUL. Multiply a series of integers and return their product.

      evaluateIntMul :−
       (form () void:
        (with var int temp :− 1
         do (for int arg in zeroOrMoreIntegers(term)
             do temp ×= arg)
            return(makeInteger(temp))))

!  EVALUATE INT NE. Test if two integers are not equal.

      evaluateIntNe :−
       (form () void:
        (for int left, int right in twoIntegers(term)
         do return(boolify(left ≠ right))))

!  EVALUATE INT NEG. Return an integer with its opposite sign.

     evaluateIntNeg :−
      (form () void:
       (for ref object arg in oneObject(term)
        do (if arg↑.tag = integerTag
            then return(makeInteger(− arg{ref integer}↑.self))
            else error(term, ''Integer expected''))))

!  EVALUATE INT NOT. Return an integer with its bits reversed.

     evaluateIntNot :−
      (form () void:
       (for ref object arg in oneObject(term)
        do (if arg↑.tag = integerTag
            then return(makeInteger(~ arg{ref integer}↑.self))
            else error(term, ''Integer expected''))))

!  EVALUATE INT OR. Disjoin a series of zero or more integers.

     evaluateIntOr :−
      (form () void:
       (with var int temp :− 0
        do (for int arg in zeroOrMoreIntegers(term)
            do temp |= arg)
           return(makeInteger(temp))))

!  EVALUATE INT SUB. Subtract the first integer from the second, and return the
!  result.

      evaluateIntSub :−
       (form () void:
        (for int left, int right in twoIntegers(term)
         do return(makeInteger(left − right))))

!  EVALUATE INT XOR. Exclusively disjoin a series of zero or more integers.

      evaluateIntXor :−
       (form () void:
        (with var int temp :− −1
         do (for int arg in zeroOrMoreIntegers(term)
             do temp ~= arg)
            return(makeInteger(temp))))

!  EVALUATE IS CONS. Test if an object is a CONS.

      evaluateIsCons :−
       (form () void:
        (for ref object arg in oneObject(term)
         do return(boolify(arg↑.tag = consTag))))

!  EVALUATE IS EOF. Test if an object is an EOF.

      evaluateIsEof :−
       (form () void:
        (for ref object arg in oneObject(term)
         do return(boolify(arg↑.tag = eofTag))))

!  EVALUATE IS HOOK. Test if an object is a HOOK.

      evaluateIsHook :−
       (form () void:
        (for ref object arg in oneObject(term)
         do return(boolify(arg↑.tag = hookTag))))

!  EVALUATE IS INT. Test if an object is an integer.

      evaluateIsInt :−
       (form () void:
        (for ref object arg in oneObject(term)
         do return(boolify(arg↑.tag = integerTag))))

!  EVALUATE IS LAMBDA. Test if an object is a LAMBDA.

      evaluateIsLambda :−
       (form () void:
        (for ref object arg in oneObject(term)
         do return(boolify(arg↑.tag = lambdaTag))))

!  EVALUATE IS NAME. Test if an object is a NAME.

      evaluateIsName :−
       (form () void:
        (for ref object arg in oneObject(term)
         do return(boolify(arg↑.tag = nameTag))))

!  EVALUATE IS NIL. Test if an object is NIL NAME.

      evaluateIsNil :−
       (form () void:
        (for ref object arg in oneObject(term)
         do return(boolify(arg = nilName))))

!  EVALUATE IS STRING. Test if an object is a string.

      evaluateIsString :−
       (form () void:
        (for ref object arg in oneObject(term)
         do return(boolify(arg↑.tag = textTag))))

!  EVALUATE LAST. Evaluate a series of arguments in order, and return the value
!  of the last argument. If there are no arguments, then return NIL NAME.

      evaluateLast :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then return(nilName)
             else (while ¬ atEnd(terms↑.cdr)
                   do evaluate(terms↑.car)
                      terms := terms↑.cdr)
                  recurse(terms↑.car))))

!  EVALUATE LET. Evaluate a LET. The following LET:
!
!              (let ((N₁ A₁) (N₂ A₂) ... (Nᵢ Aᵢ)) B₁ B₂ ... Bⱼ)
!
!  is equivalent to this LAMBDA application:
!
!            ((lambda (N₁ N₂ ... Nᵢ) B₁ B₂ ... Bⱼ) A₁ A₂ ... Aᵢ)

      evaluateLet :−
       (form () void:
        (with
          ref object     layer    :− makeLayer(layers)
          var ref object letting  :− nil
          var ref object lettings :− nil
          var ref object terms    :− term↑.cdr

!  CHECK LETTINGS. Verify that the list of (N A) pairs is well formed.

          checkLettings :−
           (form (ref object lettings) void:
            (with
              var ref object lettings      :− (past lettings)
              var ref object letting       :− nil
              var ref object name          :− nil
              var ref object otherLettings :− nil
             do (while ¬ atEnd(lettings)
                 do letting := lettings↑.car
                    (if atEnd(letting)
                     then error(term, ''Not enough arguments'')
                     else if letting↑.car↑.tag = nameTag
                          then letting := letting↑.cdr
                          else error(term, ''Parameter is not a name''))
                    (if atEnd(letting)
                     then error(term, ''Not enough arguments'')
                     else if atEnd(letting↑.cdr)
                          then lettings := lettings↑.cdr
                          else error(term, ''Too many arguments'')))
                lettings := (past lettings)
                (while ¬ atEnd(lettings)
                 do name := lettings↑.car↑.car
                    lettings := lettings↑.cdr
                    otherLettings := lettings
                    (while ¬ atEnd(otherLettings)
                     do (if name = otherLettings↑.car↑.car
                         then error(term, ''Repeated parameter name'')
                         else otherLettings := otherLettings↑.cdr)))))

!  This is EVALUATE LET's body.

         do (if atEnd(terms)
             then error(term, ''Not enough arguments'')
             else lettings := terms↑.car
                  terms := terms↑.cdr)
            checkLettings(lettings)
            (while ¬ atEnd(lettings)
             do letting := lettings↑.car
                setKey(layer, letting↑.car, evaluate(letting↑.cdr↑.car))
                lettings := lettings↑.cdr)
            (if atEnd(terms)
             then return(nilName)
             else (while ¬ atEnd(terms↑.cdr)
                   do evaluate(terms↑.car, layer)
                      terms := terms↑.cdr)
                  recurse(terms↑.car, layer))))

!  EVALUATE LIST. Evaluate a series of arguments in order, and return a list of
!  their values. If there are no arguments, return NIL NAME.

      evaluateList :−
       (form () void:
        (with
          var ref object first :− nilName
          var ref object last  :− nil
          var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then return(nilName)
             else first := makeCons(evaluate(terms↑.car), nilName)
                  last := first
                  terms := terms↑.cdr
                  (while ¬ atEnd(terms)
                   do last↑.cdr := makeCons(evaluate(terms↑.car), nilName)
                      last := last↑.cdr
                      terms := terms↑.cdr)
                  return(first))))

!  EVALUATE LOAD. Open a file that has a given pathname string. Repeatedly read
!  an expression from the file and evaluate it. Finally return the string.

      evaluateLoad :−
       (form () void:
        (for ref text arg in oneText(term)
         do (with var buffer(maxLineLength, char0) path
             do empty(path)
                (for char0 ch in elements(arg)
                 do (if isFull(path)
                     then error(term, ''Path string is too long'')
                     else append(path, ch)))
                evaluateFile(path{string}, layers)
                return(arg{ref object}))))

!  EVALUATE NAME STR. Return a TEXT that holds the characters of a NAME.

      evaluateNameStr :−
       (form () void:
        (for ref object arg in oneObject(term)
         do (if arg↑.tag = nameTag
             then return(makeText(arg{ref name}↑.chars))
             else error(term, ''Name expected''))))

!  EVALUATE OBJ EQ. Test if two objects reside at the same memory address.

      evaluateObjEq :−
       (form () void:
        (for ref object left, ref object right in twoObjects(term)
         do return(boolify(left = right))))

!  EVALUATE OBJ LEN. Return the number of elements in a noncircular list. If we
!  ask for the number of elements in a circular list, we get an error. Circular
!  lists are detected by a trick, described in:
!
!  Guy L. Steele, Jr. Common Lisp: The Language. Second Edition. Digital Press.
!  Bedford, Massachusetts. 1990. Page 414.
!
!  An object that is not a list has length 0, by definition.

      evaluateObjLen :−
       (form () void:
        (for ref object arg in oneObject(term)
         do (if arg↑.tag = consTag
             then (with
                    var int        count :− 0
                    var ref object fast  :− arg
                    var ref object slow  :− arg
                   do (while
                       (if fast↑.tag ≠ consTag
                        then false
                        else if fast↑.cdr↑.tag ≠ consTag
                             then count += 1
                                  false
                             else if fast = slow ∧ count > 0
                                  then error(term, ''Linear list expected'')
                                  else count += 2
                                       fast  := fast↑.cdr↑.cdr
                                       slow  := slow↑.cdr
                                       true))
                      return(makeInteger(count)))
             else return(makeInteger(0)))))

!  EVALUATE OBJ NE. Test if two objects reside at different memory addresses.

      evaluateObjNe :−
       (form () void:
        (for ref object left, ref object right in twoObjects(term)
         do return(boolify(left ≠ right))))

!  EVALUATE OBJ WRITE. Write an object to OUTPUT followed by a newline.

      evaluateObjWrite :−
       (form () void:
        (for ref object arg in oneObject(term)
         do writeObject(arg)
            writeln()
            return(arg)))

!  EVALUATE OR. McCarthy disjunction. Evaluate a series of arguments, in order.
!  If one returns a value that is not NIL NAME, then return that value, without
!  evaluating the others.  Otherwise, return the value of the last argument. If
!  we have no arguments, then return NIL NAME.

      evaluateOr :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then return(nilName)
                  false
             else (while
                   (if atEnd(terms↑.cdr)
                    then recurse(terms↑.car)
                         false
                    else (if value := evaluate(terms↑.car)
                             value ≠ nilName
                          then false
                          else terms := terms↑.cdr
                               true))))))

!  EVALUATE NAME. Return the binding of a NAME.

      evaluateName :−
       (form () void:
        (if ¬ gotKey(value, layers, term)
         then error(term, ''Unbound name'')))

!  EVALUATE NIL. Evaluate NIL (not NIL NAME). This is a bug and so should never
!  happen.

      evaluateNil :−
       (form () void:
         error(''Evaluated [nil]''))

!  EVALUATE QUIT. Terminate Scam and pass control back to the operating system.
!  If there is a single argument, then evaluate it to an integer, and pass that
!  integer to the operating system too.

      evaluateQuit :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then exit(0)
             else if atEnd(terms↑.cdr)
                  then (with ref object arg :− evaluate(terms↑.car)
                        do (if arg↑.tag = integerTag
                            then exit(arg{ref integer}↑.self)
                            else error(term, ''Integer expected'')))
                  else error(term, ''Too many arguments''))))

!  EVALUATE QUOTE. Return an object without evaluating it.

      evaluateQuote :−
       (form () void:
        (with ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then error(term, ''Not enough arguments'')
             else if atEnd(terms↑.cdr)
                  then return(terms↑.car)
                  else error(term, ''Too many arguments''))))

!  EVALUATE SET. Bind an unevaluated NAME to an object. The NAME must have been
!  bound at or below the current LAYER.

      evaluateSet :−
       (form () void:
        (for ref object left, ref object right in nameAndObject(term)
         do (if resetKey(layers, left, right)
             then return(right)
             else error(left, ''Undeclared name''))))

!  EVALUATE SET CAR. Reset the CAR of a CONS.

      evaluateSetCar :−
       (form () void:
        (for ref object left, ref object right in consAndObject(term)
         do left↑.car := right
            return(right)))

!  EVALUATE SET CDR. Reset the CDR of a CONS.

      evaluateSetCdr :−
       (form () void:
        (for ref object left, ref object right in consAndObject(term)
         do left↑.cdr := right
            return(right)))

!  EVALUATE SIMPLE. Return an object without evaluating it.

      evaluateSimple :−
       (form () void:
         return(term))

!  EVALUATE STR ADD. Concatenate zero or more strings.

      evaluateStrAdd :−
       (form () void:
        (with var ref object terms :− term↑.cdr
         do (if atEnd(terms)
             then return(makeText(0, 0, nil))
             else (with
                    var ref object  arg   :− nil
                    var int         count :− 0
                    var int         end   :− 0
                    var ref textlet first :− makeTextlet()
                    var ref textlet last  :− first
                   do (while
                        arg := evaluate(terms↑.car)
                        (if arg↑.tag = textTag
                         then (for char0 ch in elements(arg{ref text})
                               do (if count = textletLength
                                   then last↑.next := makeTextlet()
                                        last := last↑.next
                                        count := 0)
                                  last↑.chars[count] := ch
                                  count += 1
                                  end += 1)
                         else error(term, ''String expected''))
                        terms := terms↑.cdr
                        ¬ atEnd(terms))
                      return(makeText(0, end, first))))))

!  EVALUATE STR DATE. Return the current date and time as a string.

      evaluateStrDate :−
       (form () void:
        (if atEnd(term↑.cdr)
         then (with var buffer(maxLineLength, char0) chars
               do (for
                    int second, int minute, int hour, string meridiem,
                    int date, string month, int year, string day, string zone
                   in decoded(now())
                   do empty(chars)
                      write(chars, ''%s, %s %i, %i at %i:%02i %s %s'':
                       day, month, date, year, hour, minute, meridiem, zone)
                      return(makeText(chars{string}))))
         else error(term, ''Too many arguments'')))

!  EVALUATE STR EQ. Test if one string is equal to another.

      evaluateStrEq :−
       (form () void:
        (for ref text left, ref text right in twoTexts(term)
         do return(boolify(compareTexts(left, right) = 0))))

!  EVALUATE STR GE. Test if one string is greater than or equal to another.

      evaluateStrGe :−
       (form () void:
        (for ref text left, ref text right in twoTexts(term)
         do return(boolify(compareTexts(left, right) ≥ 0))))

!  EVALUATE STR GT. Test if one string is less than another.

      evaluateStrGt :−
       (form () void:
        (for ref text left, ref text right in twoTexts(term)
         do return(boolify(compareTexts(left, right) > 0))))

!  EVALUATE STR LE. Test if one string is less than or equal to another.

      evaluateStrLe :−
       (form () void:
        (for ref text left, ref text right in twoTexts(term)
         do return(boolify(compareTexts(left, right) ≤ 0))))

!  EVALUATE STR LEN. Return the number of CHAR1s in a TEXT.

      evaluateStrLen :−
       (form () void:
        (for ref text arg in oneText(term)
         do return(makeInteger(count(arg)))))

!  EVALUATE STR LOW. Convert upper case Roman letters in a TEXT to lower case.

      evaluateStrLow :−
       (form () void:
        (for ref text arg in oneText(term)
         do (with
              var int         count :− 0
              var int         end   :− 0
              var ref textlet first :− makeTextlet()
              var ref textlet last  :− first
             do (for char0 ch in elements(arg)
                 do (if count = textletLength
                     then last↑.next := makeTextlet()
                          last := last↑.next
                          count := 0)
                    last↑.chars[count] := lower(ch)
                    count += 1
                    end += 1)
                return(makeText(0, end, first)))))

!  EVALUATE STR LT. Test if one string is less than another.

      evaluateStrLt :−
       (form () void:
        (for ref text left, ref text right in twoTexts(term)
         do return(boolify(compareTexts(left, right) < 0))))

!  EVALUATE STR NAME. Return a NAME that holds the characters of a string. Note
!  that there's an upper limit of MAX LINE LENGTH chars on the NAME.

      evaluateStrName :−
       (form () void:
        (for ref text arg in oneText(term)
         do (with var buffer(maxLineLength, char0) chars
             do empty(chars)
                (for char0 ch in elements(arg)
                 do (if isFull(chars)
                     then error(term, ''String too long to make a name'')
                     else append(chars, ch)))
                return(makeName(chars{string})))))

!  EVALUATE STR NE. Test if two strings are unequal.

      evaluateStrNe :−
       (form () void:
        (for ref text left, ref text right in twoTexts(term)
         do return(boolify(compareTexts(left, right) ≠ 0))))

!  EVALUATE STR READ. Read a string or an EOF from INPUT.

      evaluateStrRead :−
       (form () void:
        (with var char ch :− read(input)
         do (if ch = eos
             then return(makeEof())
             else (with
                    var int         count :− 0
                    var int         end   :− 0
                    var ref textlet first :− makeTextlet()
                    var ref textlet last  :− first
                   do (while
                       (if ch = eol
                        then read(input)
                             false
                        else (if count = textletLength
                              then last↑.next := makeTextlet()
                                   last := last↑.next
                                   count := 0)
                             last↑.chars[count] := ch{char0}
                             ch := read(input)
                             count += 1
                             end += 1
                             true))
                      return(makeText(0, end, first))))))

!  EVALUATE STR SUB. Return a substring of a string. Note that we can compute a
!  substring without copying characters, in about the same amount of space as a
!  CONS. However, we can't always garbage collect unused TEXTLETs as a result.

      evaluateStrSub :−
       (form () void:
        (with
          var ref object args   :− term↑.cdr
          var ref object base   :− nil
          var int        length
          var int        limit
          var int        offset
         do (if atEnd(args)
             then error(term, ''Not enough arguments'')
             else base := evaluate(args↑.car)
                  (if base↑.tag = textTag
                   then limit := count(base{ref text})
                        args := args↑.cdr
                   else error(term, ''String expected'')))
            (if atEnd(args)
             then error(term, ''Not enough arguments'')
             else (with ref object temp :− evaluate(args↑.car)
                   do (if temp↑.tag = integerTag
                       then offset := temp{ref integer}↑.self
                            args := args↑.cdr
                       else error(term, ''Integer expected''))))
            (if atEnd(args)
             then length := limit − offset
             else (with ref object temp :− evaluate(args↑.car)
                   do (if temp↑.tag = integerTag
                       then length := temp{ref integer}↑.self − offset
                            args := args↑.cdr
                       else error(term, ''Integer expected''))))
            (if atEnd(args)
             then (if 0 ≤ offset < limit ∧ 0 ≤ length ≤ limit
                   then (if length > 0
                         then (with
                                var int         end
                                var ref textlet first :− base{ref text}↑.first
                                var int         index
                                var ref textlet last  :− nil
                                var int         start :− base{ref text}↑.start
                                var int         temp
                               do (while offset > 0
                                   do start += stride(first↑.chars[start])
                                      (if start ≥ textletLength
                                       then first := first↑.next
                                            start −= textletLength)
                                      offset −= 1)
                                  end   := start
                                  index := start
                                  last  := first
                                  (while length > 0
                                   do temp  := stride(last↑.chars[index])
                                      end   += temp
                                      index += temp
                                      (if index ≥ textletLength
                                       then last  := last↑.next
                                            index −= textletLength)
                                      length −= 1)
                                  return(makeText(start, end, first)))
                         else return(makeText(0, 0, nil)))
                   else error(term, ''Index out of range''))
             else error(term, ''Too many arguments''))))

!  EVALUATE STR UP. Convert lower case Roman letters in a TEXT to upper case.

      evaluateStrUp :−
       (form () void:
        (for ref text arg in oneText(term)
         do (with
              var int         count :− 0
              var int         end   :− 0
              var ref textlet first :− makeTextlet()
              var ref textlet last  :− first
             do (for char0 ch in elements(arg)
                 do (if count = textletLength
                     then last↑.next := makeTextlet()
                          last := last↑.next
                          count := 0)
                    last↑.chars[count] := upper(ch)
                    count += 1
                    end += 1)
                return(makeText(0, end, first)))))

!  EVALUATE STR WRITE. Write the characters of a TEXT, without punctuation.

      evaluateStrWrite :−
       (form () void:
        (for ref text arg in oneText(term)
         do (for char0 ch in elements(arg)
             do write(ch))
            return(arg{ref object})))

!  EVALUATE THROW. Terminate the currently evaluating CATCH, and make it return
!  an object. If no CATCH is evaluating, then discard the object and go back to
!  the top level.

      evaluateThrow :−
       (form () void:
        (for ref object arg in oneObject(term)
         do thrown := arg
            throw(exception)))

!  EVALUATE UNKNOWN. Evaluate an object that has an unknown TAG slot. This is a
!  bug and should never happen.

      evaluateUnknown :−
       (form () void:
         error(''Unknown expression''))

!  This is EVALUATE's body. Dispatch on TERM to the code that evaluates it. The
!  loop simulates tail recursions.

     do (while
          going := false
          (if term = nil
           then evaluateNil()
           else (case term↑.tag
                 of consTag: evaluateCall()
                     eofTag: evaluateSimple()
                    hookTag: evaluateSimple()
                  lambdaTag: evaluateSimple()
                    nameTag: evaluateName()
                 integerTag: evaluateSimple()
                    textTag: evaluateSimple()
                       none: evaluateUnknown()))
          going)
        value))

!  EVALUATE FILE. Open the text file given by the pathname PATH, which must end
!  in SUFFIX. Read and evaluate expressions from the file, then close it.

  evaluateFile :−
   (proc (string path, ref object layers) void:
    (for bool ok, string path' in canonical(path)
     do (if ok
         then (for string, string file, string suffix in pathname(path')
               do (with
                    var stream source
                    var ref object term :− nil
                   do (if suffix ≠ scamSuffix
                       then error(''load: Unexpected suffix in "%s"'': path'))
                      (if ¬ open(source, path', ''r'')
                       then error(''load: Cannot open "%s"'': path'))
                      (while
                        term := readObject(source, file)
                        term↑.tag ≠ eofTag
                       do evaluate(term, layers))
                      (if ¬ close(source)
                       then error(''load: Cannot close "%s"'': path'))))
         else error(''load: Cannot open "%s"'': path))))
)
