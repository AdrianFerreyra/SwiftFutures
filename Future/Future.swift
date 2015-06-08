//
//  Futures.swift
//  Futures
//
//  Created by Adrián Ferreyra.
//  @_AdrianFerreyra.
//
//  Copyright (c) 2015 Adrián Ferreyra. All rights reserved.
//
//

import Foundation

/**
 * Enum que modela los posibles estados de la Future. Se considera que toda Future puede fallar, por eso el resultado es tanto NotFinished, como Finished con un Optional funcionando como una Mónada Maybe (Haskell).
 */
enum FutureState<A> {
    case NotFinished
    case Finished(Optional<A>)
}

/**
 * Clase modelo de Future. Se implementa de forma generica sobre el tipo de respuesta en caso satisfactorio.
 */
class Future<A> {
    
    /**
    * Estado de la mónada.
    */
    var result: FutureState<A> {
        didSet {
            switch result {
            case .Finished(let resultData):
                if let callback = callback {
                    callback(resultData)
                }
            default:
                break
            }
        }
    }
    
    /**
    * Callback a llamarse cuando se setee un resultado finalizado a la mónada o en caso de ya tener resultado e setear un callback. (Casos de seteo de callback sobre mónadas ya completas).
    */
    var callback: (A? -> Void)? = nil {
        didSet {
            switch result {
            case .Finished(let resultData):
                if let callback = callback {
                    callback(resultData)
                }
            default:
                break
            }
        }
    }
    
    /**
    * Inicialización sin parámetros.
    */
    init () {
        result = .NotFinished
    }
    
    /**
    * Inicialización con valor.
    */
    init (_ x:A) {
        result = .Finished(x)
    }
    
    /**
     * Función bind. Permite unwrappear el valor contenido en la mónada y aplicarlo a la función f, para luego devolver la mónada resultado de la aplicación.
     * :param: self Mónada sobre la que se va a realizar la operación.
     * :param: f función con Optional de A como input y Future como resultado
     * :return: Future Future resultado de función.
     */
    func bind <B>(f:A? -> Future<B>) -> Future<B> {
        var returnFuture = Future<B>()
        
        self.callback = {(x:A?) in
                            var secondFuture = f(x)
                            secondFuture.callback = { (y:B?) -> Void in
                                returnFuture.result = .Finished(y)
                            }
        }
        
        return returnFuture
    }
}

/**
 * Función identidad. Permite obtener la forma monádica del valor.
 * :param: x Valor a embeber en mónada.
 * :return: Future forma monádica del valor.
 */
func unit<A>(x:A) -> Future<A> {
    return Future(x)
}

/**
* Declaración del operador infijo bind.
*/
infix operator >>>= {associativity left}

func >>>= <A,B>(m:Future<A>,f:A? -> Future<B>) -> Future<B> {
    return m.bind(f)
}
