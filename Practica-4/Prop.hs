--Espinal Cruces Martin Felipe 316155362
--Fernandez Aguilar Alex Gerardo 314338097
--Luis Erick Montes Garcia 419004547

module Prop where 
 
 import Data.List


--DEFINICIONES 

-- Tipo de dato para representar las expresiones de la lógica proposicional
 data Prop = Verdadero
           | Falso 
           | Var String
           | Neg Prop
           | Conj Prop Prop
           | Disy Prop Prop
           | Impl Prop Prop
           | Syss Prop Prop
           deriving (Eq,Ord)

-- Sinónimo para representar el estado
 type Estado = [(String,Prop)]

--Instancia de Show para el tipo Prop, para que sea legible lo que se imprime en consola
-- NO DEFINE COMPORTAMIENTO
 instance Show Prop where 
  show Verdadero = "V" -- V
  show Falso = "F" -- F
  show (Var x) = x -- P 
  show (Neg p) = "¬ " ++ show p -- ¬ P
  show (Conj p q) = "(" ++ show p ++ " && " ++ show q ++ ")" -- (P ∧ Q)
  show (Disy p q) = "(" ++ show p ++ " || " ++ show q ++ ")" -- (P ∨ Q)
  show (Impl p q) = "(" ++ show p ++ " -> " ++ show q ++ ")" -- (P → Q)
  show (Syss p q) = "(" ++ show p ++ " <-> " ++ show q ++ ")" -- (P ↔ Q)


-- EQUIVALENCIAS LÓGICAS 

 -- Ejercicio 1.1
 eliminacion :: Prop -> Prop
 -- la eliminacion de la implicacion y la doble implicacion solo note que en el pdf la segunda parte de la doble implicacion estaba al revez pero esta solucionado
 -- se busca primero los casos importantes y despues los demas se descomponen para encontrar mas variables hasta que ya no hay aforma de descomponerlo en algo mas simple
 eliminacion (Impl (x) (y)) = (Disy (Neg (eliminacion x)) (eliminacion y))
 eliminacion (Syss (x) (y)) = (Conj (Disy (Neg (eliminacion x)) (eliminacion y)) (Disy (Neg (eliminacion y)) (eliminacion x)))
 eliminacion (Neg (p)) = (Neg (eliminacion p))
 eliminacion (Conj (x) (y)) = (Conj (eliminacion x) (eliminacion y))
 eliminacion (Disy (x) (y)) = (Disy (eliminacion x) (eliminacion y))
 --resumi los casos de verdadero falso y var con este modelo de abajo , lo puse hasta abajo para que solo sea como ultimo recurso si no encuentra con que empatar antes
 eliminacion (p) = (p)

 -- Ejercicio 1.2
 deMorgan :: Prop -> Prop
-- aplica deMorgan a todos los casos donde exista una negacion y una conjuncion o disyuncion
-- se busca primero los casos importantes y despues los demas se descomponen para encontrar mas variables hasta que ya no hay aforma de descomponerlo en algo mas simple
 deMorgan (Neg (Conj (x) (y) )) = (Disy (Neg (deMorgan x)) (Neg (deMorgan y)) )
 deMorgan (Neg (Disy (x) (y) )) = (Conj (Neg (deMorgan x)) (Neg (deMorgan y)) )
 deMorgan (Impl (x) (y)) = (Impl (deMorgan x) (deMorgan y))
 deMorgan (Syss (x) (y)) = (Syss (deMorgan x) (deMorgan y))
 deMorgan (Conj (x) (y)) = (Conj (deMorgan x) (deMorgan y))
 deMorgan (Disy (x) (y)) = (Disy (deMorgan x) (deMorgan y))
 --resumi los casos de verdadero falso y var con este modelo de abajo , lo puse hasta abajo para que solo sea como ultimo recurso si no encuentra con que empatar antes
 deMorgan (p) = (p) 

-- EVALUACIÓN Y ANÁLISIS SINTÁCTICO DE EXPRESIONES

 -- Ejercicio 2.1 
 interp :: Prop -> Estado -> Bool
 -- valua junto con el estado y la funcion auxiliar  
 interp (Verdadero) e = True
 interp (Falso) e = False
 interp (Var x ) e = interp (buscar x e) []
 interp (Neg (x) ) e = not (interp x e)
 interp (Conj (x) (y) ) e = (interp x e)&&(interp y e)
 interp (Disy (x) (y) ) e = (interp x e)||(interp y e)
 interp (Impl (x) (y) ) e = interp (eliminacion (Impl (x) (y) )) e
 interp (Syss (x) (y) ) e = interp (eliminacion (Syss (x) (y) )) e

--funcion auxiliar busca el string en el primer elelemnto de la lista de tubplas
--no lo hice en una lambda porque si existe el caso de que no existe el String en el estado no funcionara
 buscar :: String -> Estado -> Prop
 buscar a ((x,y):xs)
  | (a == x) = y
  | otherwise = buscar a xs
 buscar a [] = error"No esta la variable en el estado"


  -- Ejercicio 2.2
 truthTable :: Prop -> String
 truthTable p 
  | ([True] == (nub (table p (estados p ) ))) = "Tautología"
  | ([False] == (nub (table p (estados p ) ))) = "Contradicción"
  | otherwise = "Contingencia"


 table :: Prop -> [Estado] -> [Bool]
 table p [] = []
 table p (x:xs) = (interp p x ): table p xs

 quitaRepetidosPar ::(Eq a) => [(a,b)] -> [(a,b)]
 quitaRepetidosPar [] = []
 quitaRepetidosPar ((a,b):xs) = (a,b):quitaRepetidosPar ([(x,y)| (x,y) <- (xs), x/=a])

 -- Función que calcula todos los posibles estados de una Prop.
 estados :: Prop -> [Estado]
 estados p = nub -- Elminamos los estados que pudieran estar repetidos.
            -- Ordenamos cada uno de los estados.
            $ map sort
              -- Dejamos una única aparicion de las variables en cada estado.
              $ map quitaRepetidosPar
              -- Calculamos todas las permutaciondes de las
              --combinaciones de las Variables con las constantes lógicas
              $ permutations [(x,y) | x <- (nub(variables p)), y <- [Verdadero,Falso]]
 

 variables :: Prop -> [String]
 variables (Var x) = [x]
 variables (Neg x) = (variables(x))
 variables (Conj x y) = (variables (x))++(variables (y))
 variables (Disy x y) = (variables (x))++(variables (y))
 variables (Impl x y) = (variables (x))++(variables (y))
 variables (Syss x y) = (variables (x))++(variables (y))
 variables p = []



 -- Ejercicio 2.3  
 correcto :: [Prop] -> Prop -> Bool 
  -- Aquí va tu código
 correcto = error "Función no definida"

