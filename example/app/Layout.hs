{-# LANGUAGE OverloadedStrings #-}
module Layout where

import RAC
import RCL
import Language.C.Syntax
import Data.Loc

layout :: Stm
layout = flip Block noLoc layout'

layout' = runExpr $ do
  textField <- newTextField "self.textField" "self.contentView"
  scrollView <- newScrollView "self.scrollView" "self.contentView"
    
  rect <- rcl_frameSignal "self.contentView" >>= insetWidthHeightNull (RCLBox 32.25) (RCLBox 16.75) (CGRectZero)
  (textRect, scrollRect) <- divideWithAmountPaddingEdge (RCLBox 20) (rac_sigsize "self.verticalPadding") (NSLayoutAttributeBottom) rect
  return $
        [ mkRCL scrollView [(Rcl_rect, scrollRect)]
        , mkRCL textField [(Rcl_rect, textRect)]
        ]
