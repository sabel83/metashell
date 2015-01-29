//===-- IR/Statepoint.cpp -- gc.statepoint utilities ---  -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// 
//===----------------------------------------------------------------------===//

#include "llvm/IR/Function.h"
#include "llvm/IR/Constant.h"
#include "llvm/IR/Constants.h"
#include "llvm/Support/CommandLine.h"

#include "llvm/IR/Statepoint.h"

using namespace std;
using namespace llvm;

bool llvm::isStatepoint(const ImmutableCallSite &CS) {
  const Function *F = CS.getCalledFunction();
  return (F && F->getIntrinsicID() == Intrinsic::experimental_gc_statepoint);
}
bool llvm::isStatepoint(const Instruction *inst) {
  if (isa<InvokeInst>(inst) || isa<CallInst>(inst)) {
    ImmutableCallSite CS(inst);
    return isStatepoint(CS);
  }
  return false;
}
bool llvm::isStatepoint(const Instruction &inst) {
  return isStatepoint(&inst);
}

bool llvm::isGCRelocate(const ImmutableCallSite &CS) {
  return isGCRelocate(CS.getInstruction());
}
bool llvm::isGCRelocate(const Instruction *inst) {
  if (const CallInst *call = dyn_cast<CallInst>(inst)) {
    if (const Function *F = call->getCalledFunction()) {
      return F->getIntrinsicID() == Intrinsic::experimental_gc_relocate;
    }
  }
  return false;
}

bool llvm::isGCResult(const ImmutableCallSite &CS) {
  return isGCResult(CS.getInstruction());
}
bool llvm::isGCResult(const Instruction *inst) {
  if (const CallInst *call = dyn_cast<CallInst>(inst)) {
    if (Function *F = call->getCalledFunction()) {
      return (F->getIntrinsicID() == Intrinsic::experimental_gc_result_int ||
              F->getIntrinsicID() == Intrinsic::experimental_gc_result_float ||
              F->getIntrinsicID() == Intrinsic::experimental_gc_result_ptr);
    }
  }
  return false;
}