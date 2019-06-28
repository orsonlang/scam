!
!  SCAM/INSTALL. Bind various names to objects.
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

!  INSTALL HOOK. Make a NAME using CHARS, and make a HOOK using CHARS and CODE.
!  Bind the NAME to the HOOK in LAYERS. Return the HOOK.

  installHook :−
   (proc (string chars, int code) ref object:
    (with ref object hook :− makeHook(chars, code)
     do setKey(layers, makeName(chars), hook)
        hook))

!  INSTALL NAME. Make a NAME using CHARS and bind the NAME to itself in LAYERS.
!  Return the NAME.

  installName :−
   (proc (string chars) ref object:
    (with ref object name :− makeName(chars)
     do setKey(layers, name, name)
        name))

!  Bind various names to HOOKs.

  init :−
   (installHook(''and'',      andCode)       !  Logical conjunction.
    installHook(''car'',      carCode)       !  CAR of a cons.
    installHook(''catch'',    catchCode)     !  Receive control from a THROW.
    installHook(''cdr'',      cdrCode)       !  CDR of a cons.
    installHook(''cons'',     consCode)      !  Make a new cons.
    installHook(''define'',   defineCode)    !  Bind name globally.
    installHook(''first'',    firstCode)     !  Value of 1st term in sequence.
    installHook(''if'',       ifCode)        !  If then else.
    installHook(''imply'',    implyCode)     !  Logical implication.
    installHook(''include'',  includeCode)   !  Load an unloaded file.
    installHook(''intAdd'',   intAddCode)    !  Add zero or more integers.
    installHook(''intAnd'',   intAndCode)    !  Bit AND zero or more integers.
    installHook(''intDiv'',   intDivCode)    !  Divide two integers.
    installHook(''intEq'',    intEqCode)     !  Integer equal test.
    installHook(''intGe'',    intGeCode)     !  Integer greater or equal test.
    installHook(''intGt'',    intGtCode)     !  Integer greater test.
    installHook(''intLe'',    intLeCode)     !  Integer less or equal test.
    installHook(''intLt'',    intLtCode)     !  Integer less test.
    installHook(''intMod'',   intModCode)    !  Modulus of two integers.
    installHook(''intMul'',   intMulCode)    !  Multiply zero or more integers.
    installHook(''intNe'',    intNeCode)     !  Integer not equal test.
    installHook(''intNeg'',   intNegCode)    !  Integer sign change.
    installHook(''intNot'',   intNotCode)    !  Integer bit NOT.
    installHook(''intOr'',    intOrCode)     !  Logical disjunction.
    installHook(''intSub'',   intSubCode)    !  Subtract two integers.
    installHook(''intXor'',   intXorCode)    !  Bit XOR zero or more integers.
    installHook(''isCons'',   isConsCode)    !  Test for cons.
    installHook(''isEof'',    isEofCode)     !  Test for EOF.
    installHook(''isHook'',   isHookCode)    !  Test for hook.
    installHook(''isInt'',    isIntCode)     !  Test for integer.
    installHook(''isLambda'', isLambdaCode)  !  Test for lambda.
    installHook(''isName'',   isNameCode)    !  Test for name.
    installHook(''isNil'',    isNilCode)     !  Test for NIL.
    installHook(''isString'', isStringCode)  !  Test for string.
    installHook(''isλ'',      isLambdaCode)  !  Test for lambda.
    installHook(''lambda'',   lambdaCode)    !  Make a new lambda.
    installHook(''last'',     lastCode)      !  Value of last term in sequence.
    installHook(''let'',      letCode)       !  Bind names locally.
    installHook(''list'',     listCode)      !  Make a new list.
    installHook(''load'',     loadCode)      !  Evaluate terms from a file.
    installHook(''nameStr'',  nameStrCode)   !  Convert a name to a string.
    installHook(''not'',      isNilCode)     !  Test for NIL.
    installHook(''objEq'',    objEqCode)     !  Object identicality test.
    installHook(''objLen'',   objLenCode)    !  Object length.
    installHook(''objNe'',    objNeCode)     !  Object nonidenticality test.
    installHook(''objWrite'', objWriteCode)  !  Write object.
    installHook(''or'',       orCode)        !  Logical disjunction.
    installHook(''quit'',     quitCode)      !  Halt Scam.
    installHook(''set'',      setCode)       !  Rebind a bound name.
    installHook(''setCar'',   setCarCode)    !  Reset the CAR of a cons.
    installHook(''setCdr'',   setCdrCode)    !  Reset the CDR of a cons.
    installHook(''strAdd'',   strAddCode)    !  Catenate zero or more strings.
    installHook(''strDate'',  strDateCode)   !  Current date as a string.
    installHook(''strEq'',    strEqCode)     !  String equal test.
    installHook(''strGe'',    strGeCode)     !  String greater or equal test.
    installHook(''strGt'',    strGtCode)     !  String greater test.
    installHook(''strLe'',    strLeCode)     !  String less or equal test.
    installHook(''strLen'',   strLenCode)    !  String length.
    installHook(''strLow'',   strLowCode)    !  String letters to lower case.
    installHook(''strLt'',    strLtCode)     !  String less test.
    installHook(''strName'',  strNameCode)   !  Convert a string to a name.
    installHook(''strNe'',    strNeCode)     !  String not equal test.
    installHook(''strRead'',  strReadCode)   !  Read a string.
    installHook(''strSub'',   strSubCode)    !  String substring.
    installHook(''strUp'',    strUpCode)     !  String letters to upper case.
    installHook(''strWrite'', strWriteCode)  !  Write a string.
    installHook(''throw'',    throwCode)     !  Pass control to deepest CATCH.
    installHook(''λ'',        lambdaCode)    !  Make a new lambda.
    skip)

!  Make various distinguished objects.

  ref object nilName   :− installName(''nil'')
  ref object quoteHook :− installHook(''quote'', quoteCode)
  ref object trueName  :− installName(''true'')
)
