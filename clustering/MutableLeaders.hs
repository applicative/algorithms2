module MutableLeaders (
    create,
    numberOfComponents,
    inSameComponent,
    union
    )
    where

import System.CPUTime
import Control.DeepSeq
import Data.Array.IO
import Data.Array.MArray
import Data.Array
import Debug.Trace
import qualified Data.Set as Set

-- myArray = do 
--     arr <- newArray (1,10) 37 :: IO (IOArray Int Int)
--     a <- readArray arr 1
--     writeArray arr 1 64
--     b <- readArray arr 1 
--     print (a,b)
    
    
create :: (Int, Int) -> IO (IOArray Int Int)
create (start, end) = do 
    actualArray <- newArray (start,end) 0
    ls <- getAssocs actualArray
    sequence $ map (\(idx, val) -> writeArray actualArray idx val) (map (\(idx,val) -> (idx, idx)) ls)
    return actualArray
    
numberOfComponents :: IO (IOArray Int Int) -> IO (Int)
numberOfComponents arrayContainer = do
    actualArray <- arrayContainer
    ls <- getAssocs actualArray
    return $ (length . (Prelude.filter (\(idx, parent) -> idx == parent)) ) ls 
    
inSameComponent :: IO (IOArray Int Int) -> Int -> Int -> IO (Bool)   
inSameComponent arrayContainer x y = do 
    actualArray <- arrayContainer
    xLeader <- readArray actualArray x
    yLeader <- readArray actualArray y
    return $ (xLeader == yLeader)
      
findParent :: IOArray Int Int -> Int -> IO Int
findParent actualArray index = do
    parent <- readArray actualArray index
    return parent
    if parent == index 
        then return parent
    else
        findParent actualArray parent

union :: Int -> Int ->  IO (IOArray Int Int) -> IO (IOArray Int Int)
union x y arrayContainer = do    
    actualArray <- arrayContainer    
    leader1 <- findParent actualArray x
    leader2 <- findParent actualArray y
    let newValues = if leader1 == leader2 then [] else [(leader1, leader2)]
    sequence $ map (\(idx, val) -> writeArray actualArray idx val) newValues
    return actualArray  

update :: IO (IOArray Int Int) -> Int -> Int -> Int -> IO (IOArray Int Int)
update arrayContainer index newValue checkValue = do
     actualArray <- arrayContainer
     lookedUpValue <- readArray actualArray index
     if lookedUpValue == checkValue then 
         writeArray actualArray index newValue         
     else
         writeArray actualArray index lookedUpValue         
     return actualArray    