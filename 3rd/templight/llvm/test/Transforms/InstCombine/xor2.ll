; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; PR1253
define i1 @test0(i32 %A) {
; CHECK-LABEL: @test0(
; CHECK-NEXT:    [[C:%.*]] = icmp slt i32 [[A:%.*]], 0
; CHECK-NEXT:    ret i1 [[C]]
;
  %B = xor i32 %A, -2147483648
  %C = icmp sgt i32 %B, -1
  ret i1 %C
}

define <2 x i1> @test0vec(<2 x i32> %A) {
; CHECK-LABEL: @test0vec(
; CHECK-NEXT:    [[C:%.*]] = icmp slt <2 x i32> [[A:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %B = xor <2 x i32> %A, <i32 -2147483648, i32 -2147483648>
  %C = icmp sgt <2 x i32> %B, <i32 -1, i32 -1>
  ret <2 x i1> %C
}

define i1 @test1(i32 %A) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[C:%.*]] = icmp slt i32 [[A:%.*]], 0
; CHECK-NEXT:    ret i1 [[C]]
;
  %B = xor i32 %A, 12345
  %C = icmp slt i32 %B, 0
  ret i1 %C
}

; PR1014
define i32 @test2(i32 %tmp1) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[OVM:%.*]] = and i32 [[TMP1:%.*]], 32
; CHECK-NEXT:    [[OV1101:%.*]] = or i32 [[OVM]], 8
; CHECK-NEXT:    ret i32 [[OV1101]]
;
  %ovm = and i32 %tmp1, 32
  %ov3 = add i32 %ovm, 145
  %ov110 = xor i32 %ov3, 153
  ret i32 %ov110
}

define i32 @test3(i32 %tmp1) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[OVM:%.*]] = and i32 [[TMP1:%.*]], 32
; CHECK-NEXT:    [[OV1101:%.*]] = or i32 [[OVM]], 8
; CHECK-NEXT:    ret i32 [[OV1101]]
;
  %ovm = or i32 %tmp1, 145
  %ov31 = and i32 %ovm, 177
  %ov110 = xor i32 %ov31, 153
  ret i32 %ov110
}

; defect-2 in rdar://12329730
; (X^C1) >> C2) ^ C3 -> (X>>C2) ^ ((C1>>C2)^C3)
;   where the "X" has more than one use
define i32 @test5(i32 %val1) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[VAL1:%.*]], 1234
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 [[VAL1]], 8
; CHECK-NEXT:    [[XOR1:%.*]] = xor i32 [[SHR]], 5
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[XOR1]], [[XOR]]
; CHECK-NEXT:    ret i32 [[ADD]]
;
  %xor = xor i32 %val1, 1234
  %shr = lshr i32 %xor, 8
  %xor1 = xor i32 %shr, 1
  %add = add i32 %xor1, %xor
  ret i32 %add
}

; defect-1 in rdar://12329730
; Simplify (X^Y) -> X or Y in the user's context if we know that
; only bits from X or Y are demanded.
; e.g. the "x ^ 1234" can be optimized into x in the context of "t >> 16".
;  Put in other word, t >> 16 -> x >> 16.
; unsigned foo(unsigned x) { unsigned t = x ^ 1234; ;  return (t >> 16) + t;}
define i32 @test6(i32 %x) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[X:%.*]], 1234
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 [[X]], 16
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[SHR]], [[XOR]]
; CHECK-NEXT:    ret i32 [[ADD]]
;
  %xor = xor i32 %x, 1234
  %shr = lshr i32 %xor, 16
  %add = add i32 %shr, %xor
  ret i32 %add
}


; (A | B) ^ (~A) -> (A | ~B)
define i32 @test7(i32 %a, i32 %b) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[B_NOT:%.*]] = xor i32 [[B:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = or i32 [[B_NOT]], [[A:%.*]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %or = or i32 %a, %b
  %neg = xor i32 %a, -1
  %xor = xor i32 %or, %neg
  ret i32 %xor
}

; (~A) ^ (A | B) -> (A | ~B)
define i32 @test8(i32 %a, i32 %b) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[B_NOT:%.*]] = xor i32 [[B:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = or i32 [[B_NOT]], [[A:%.*]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %neg = xor i32 %a, -1
  %or = or i32 %a, %b
  %xor = xor i32 %neg, %or
  ret i32 %xor
}

; (A & B) ^ (A ^ B) -> (A | B)
define i32 @test9(i32 %b, i32 %c) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[XOR2:%.*]] = or i32 [[B:%.*]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[XOR2]]
;
  %and = and i32 %b, %c
  %xor = xor i32 %b, %c
  %xor2 = xor i32 %and, %xor
  ret i32 %xor2
}

; (A & B) ^ (B ^ A) -> (A | B)
define i32 @test9b(i32 %b, i32 %c) {
; CHECK-LABEL: @test9b(
; CHECK-NEXT:    [[XOR2:%.*]] = or i32 [[B:%.*]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[XOR2]]
;
  %and = and i32 %b, %c
  %xor = xor i32 %c, %b
  %xor2 = xor i32 %and, %xor
  ret i32 %xor2
}

; (A ^ B) ^ (A & B) -> (A | B)
define i32 @test10(i32 %b, i32 %c) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[XOR2:%.*]] = or i32 [[B:%.*]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[XOR2]]
;
  %xor = xor i32 %b, %c
  %and = and i32 %b, %c
  %xor2 = xor i32 %xor, %and
  ret i32 %xor2
}

; (A ^ B) ^ (A & B) -> (A | B)
define i32 @test10b(i32 %b, i32 %c) {
; CHECK-LABEL: @test10b(
; CHECK-NEXT:    [[XOR2:%.*]] = or i32 [[B:%.*]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[XOR2]]
;
  %xor = xor i32 %b, %c
  %and = and i32 %c, %b
  %xor2 = xor i32 %xor, %and
  ret i32 %xor2
}

define i32 @test11(i32 %A, i32 %B) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[XOR1:%.*]] = xor i32 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    [[XOR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[XOR1]], [[XOR2]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %xor1 = xor i32 %B, %A
  %not = xor i32 %A, -1
  %xor2 = xor i32 %not, %B
  %and = and i32 %xor1, %xor2
  ret i32 %and
}

define i32 @test11b(i32 %A, i32 %B) {
; CHECK-LABEL: @test11b(
; CHECK-NEXT:    [[XOR1:%.*]] = xor i32 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    [[XOR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[XOR1]], [[XOR2]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %xor1 = xor i32 %B, %A
  %not = xor i32 %A, -1
  %xor2 = xor i32 %not, %B
  %and = and i32 %xor2, %xor1
  ret i32 %and
}

define i32 @test11c(i32 %A, i32 %B) {
; CHECK-LABEL: @test11c(
; CHECK-NEXT:    [[XOR1:%.*]] = xor i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    [[XOR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[XOR1]], [[XOR2]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %xor1 = xor i32 %A, %B
  %not = xor i32 %A, -1
  %xor2 = xor i32 %not, %B
  %and = and i32 %xor1, %xor2
  ret i32 %and
}

define i32 @test11d(i32 %A, i32 %B) {
; CHECK-LABEL: @test11d(
; CHECK-NEXT:    [[XOR1:%.*]] = xor i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    [[XOR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[XOR1]], [[XOR2]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %xor1 = xor i32 %A, %B
  %not = xor i32 %A, -1
  %xor2 = xor i32 %not, %B
  %and = and i32 %xor2, %xor1
  ret i32 %and
}

define i32 @test11e(i32 %A, i32 %B, i32 %C) {
; CHECK-LABEL: @test11e(
; CHECK-NEXT:    [[FORCE:%.*]] = mul i32 [[B:%.*]], [[C:%.*]]
; CHECK-NEXT:    [[XOR1:%.*]] = xor i32 [[FORCE]], [[A:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[FORCE]], [[A]]
; CHECK-NEXT:    [[XOR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[XOR1]], [[XOR2]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %force = mul i32 %B, %C
  %xor1 = xor i32 %force, %A
  %not = xor i32 %A, -1
  %xor2 = xor i32 %force, %not
  %and = and i32 %xor1, %xor2
  ret i32 %and
}

define i32 @test11f(i32 %A, i32 %B, i32 %C) {
; CHECK-LABEL: @test11f(
; CHECK-NEXT:    [[FORCE:%.*]] = mul i32 [[B:%.*]], [[C:%.*]]
; CHECK-NEXT:    [[XOR1:%.*]] = xor i32 [[FORCE]], [[A:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[FORCE]], [[A]]
; CHECK-NEXT:    [[XOR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[XOR1]], [[XOR2]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %force = mul i32 %B, %C
  %xor1 = xor i32 %force, %A
  %not = xor i32 %A, -1
  %xor2 = xor i32 %force, %not
  %and = and i32 %xor2, %xor1
  ret i32 %and
}

define i32 @test12(i32 %a, i32 %b) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %negb = xor i32 %b, -1
  %and = and i32 %a, %negb
  %nega = xor i32 %a, -1
  %xor = xor i32 %and, %nega
  ret i32 %xor
}

define i32 @test12commuted(i32 %a, i32 %b) {
; CHECK-LABEL: @test12commuted(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %negb = xor i32 %b, -1
  %and = and i32 %negb, %a
  %nega = xor i32 %a, -1
  %xor = xor i32 %and, %nega
  ret i32 %xor
}

; This is a test of canonicalization via operand complexity.
; The final xor has a binary operator and a (fake) unary operator,
; so binary (more complex) should come first.

define i32 @test13(i32 %a, i32 %b) {
; CHECK-LABEL: @test13(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %negb = xor i32 %b, -1
  %and = and i32 %a, %negb
  %xor = xor i32 %nega, %and
  ret i32 %xor
}

define i32 @test13commuted(i32 %a, i32 %b) {
; CHECK-LABEL: @test13commuted(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %negb = xor i32 %b, -1
  %and = and i32 %negb, %a
  %xor = xor i32 %nega, %and
  ret i32 %xor
}

; (A ^ C) ^ (A | B) -> ((~A) & B) ^ C

define i32 @xor_or_xor_common_op_commute1(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @xor_or_xor_common_op_commute1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[TMP2]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %a, %c
  %ab = or i32 %a, %b
  %r = xor i32 %ac, %ab
  ret i32 %r
}

; (C ^ A) ^ (A | B) -> ((~A) & B) ^ C

define i32 @xor_or_xor_common_op_commute2(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @xor_or_xor_common_op_commute2(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[TMP2]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %c, %a
  %ab = or i32 %a, %b
  %r = xor i32 %ac, %ab
  ret i32 %r
}

; (A ^ C) ^ (B | A) -> ((~A) & B) ^ C

define i32 @xor_or_xor_common_op_commute3(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @xor_or_xor_common_op_commute3(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[TMP2]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %a, %c
  %ab = or i32 %b, %a
  %r = xor i32 %ac, %ab
  ret i32 %r
}

; (C ^ A) ^ (B | A) -> ((~A) & B) ^ C

define i32 @xor_or_xor_common_op_commute4(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @xor_or_xor_common_op_commute4(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[TMP2]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %c, %a
  %ab = or i32 %b, %a
  %r = xor i32 %ac, %ab
  ret i32 %r
}

; (A | B) ^ (A ^ C) -> ((~A) & B) ^ C

define i32 @xor_or_xor_common_op_commute5(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @xor_or_xor_common_op_commute5(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[TMP2]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %a, %c
  %ab = or i32 %a, %b
  %r = xor i32 %ab, %ac
  ret i32 %r
}

; (A | B) ^ (C ^ A) -> ((~A) & B) ^ C

define i32 @xor_or_xor_common_op_commute6(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @xor_or_xor_common_op_commute6(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[TMP2]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %c, %a
  %ab = or i32 %a, %b
  %r = xor i32 %ab, %ac
  ret i32 %r
}

; (B | A) ^ (A ^ C) -> ((~A) & B) ^ C

define i32 @xor_or_xor_common_op_commute7(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @xor_or_xor_common_op_commute7(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[TMP2]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %a, %c
  %ab = or i32 %b, %a
  %r = xor i32 %ab, %ac
  ret i32 %r
}

; (B | A) ^ (C ^ A) -> ((~A) & B) ^ C

define i32 @xor_or_xor_common_op_commute8(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @xor_or_xor_common_op_commute8(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[TMP2]], [[C:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %c, %a
  %ab = or i32 %b, %a
  %r = xor i32 %ab, %ac
  ret i32 %r
}

define i32 @xor_or_xor_common_op_extra_use1(i32 %a, i32 %b, i32 %c, i32* %p) {
; CHECK-LABEL: @xor_or_xor_common_op_extra_use1(
; CHECK-NEXT:    [[AC:%.*]] = xor i32 [[A:%.*]], [[C:%.*]]
; CHECK-NEXT:    store i32 [[AC]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[AB:%.*]] = or i32 [[A]], [[B:%.*]]
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[AC]], [[AB]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %a, %c
  store i32 %ac, i32* %p
  %ab = or i32 %a, %b
  %r = xor i32 %ac, %ab
  ret i32 %r
}

define i32 @xor_or_xor_common_op_extra_use2(i32 %a, i32 %b, i32 %c, i32* %p) {
; CHECK-LABEL: @xor_or_xor_common_op_extra_use2(
; CHECK-NEXT:    [[AC:%.*]] = xor i32 [[A:%.*]], [[C:%.*]]
; CHECK-NEXT:    [[AB:%.*]] = or i32 [[A]], [[B:%.*]]
; CHECK-NEXT:    store i32 [[AB]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[AC]], [[AB]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %a, %c
  %ab = or i32 %a, %b
  store i32 %ab, i32* %p
  %r = xor i32 %ac, %ab
  ret i32 %r
}

define i32 @xor_or_xor_common_op_extra_use3(i32 %a, i32 %b, i32 %c, i32* %p1, i32* %p2) {
; CHECK-LABEL: @xor_or_xor_common_op_extra_use3(
; CHECK-NEXT:    [[AC:%.*]] = xor i32 [[A:%.*]], [[C:%.*]]
; CHECK-NEXT:    store i32 [[AC]], i32* [[P1:%.*]], align 4
; CHECK-NEXT:    [[AB:%.*]] = or i32 [[A]], [[B:%.*]]
; CHECK-NEXT:    store i32 [[AB]], i32* [[P2:%.*]], align 4
; CHECK-NEXT:    [[R:%.*]] = xor i32 [[AC]], [[AB]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %ac = xor i32 %a, %c
  store i32 %ac, i32* %p1
  %ab = or i32 %a, %b
  store i32 %ab, i32* %p2
  %r = xor i32 %ac, %ab
  ret i32 %r
}

define i8 @test15(i8 %A, i8 %B) {
; CHECK-LABEL: @test15(
; CHECK-NEXT:    [[XOR1:%.*]] = xor i8 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor i8 [[A]], [[B]]
; CHECK-NEXT:    [[XOR2:%.*]] = xor i8 [[TMP1]], 33
; CHECK-NEXT:    [[AND:%.*]] = and i8 [[XOR1]], [[XOR2]]
; CHECK-NEXT:    [[RES:%.*]] = mul i8 [[AND]], [[XOR2]]
; CHECK-NEXT:    ret i8 [[RES]]
;
  %xor1 = xor i8 %B, %A
  %not = xor i8 %A, 33
  %xor2 = xor i8 %not, %B
  %and = and i8 %xor1, %xor2
  %res = mul i8 %and, %xor2 ; to increase the use count for the xor
  ret i8 %res
}

define i8 @test16(i8 %A, i8 %B) {
; CHECK-LABEL: @test16(
; CHECK-NEXT:    [[XOR1:%.*]] = xor i8 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor i8 [[A]], [[B]]
; CHECK-NEXT:    [[XOR2:%.*]] = xor i8 [[TMP1]], 33
; CHECK-NEXT:    [[AND:%.*]] = and i8 [[XOR2]], [[XOR1]]
; CHECK-NEXT:    [[RES:%.*]] = mul i8 [[AND]], [[XOR2]]
; CHECK-NEXT:    ret i8 [[RES]]
;
  %xor1 = xor i8 %B, %A
  %not = xor i8 %A, 33
  %xor2 = xor i8 %not, %B
  %and = and i8 %xor2, %xor1
  %res = mul i8 %and, %xor2 ; to increase the use count for the xor
  ret i8 %res
}
