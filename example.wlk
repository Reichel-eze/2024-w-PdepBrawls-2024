/*
En este juego se pueden tener varios personajes con los cuales participar de distintas misiones. 
Cada personaje tiene una cierta cantidad de copas ganadas y al realizar una misión puede pasar
que los personajes ganen o pierdan copas.
*/

class Personaje {
  var copasGanadas = 0

  method sumarCopas(cantidad) {
    copasGanadas += cantidad
  }

  method restarCopas(cantidad) {
    copasGanadas -= cantidad
  } 

  // metodo mas general (lo voy a usar tanto para sumar como para restar)
  method darCopas(cantidad) {
    copasGanadas += cantidad
  }

}

class Arquero inherits Personaje {
  var agilidad
  var rango

  method destreza() = agilidad * rango
  method tieneEstrategia() = rango > 100
}

class Guerrerra inherits Personaje {
  var tieneEstrategia // hay guerreras que tienen estratria y guerreras que NO (por lo tanto es una variable)
  var fuerza

  method destreza() = 1.5 * fuerza    // su destreza es 50% mas que su fuerza 
  method tieneEstrategia() = tieneEstrategia
}

class Ballestero inherits Arquero {
  override method destreza() = super() * 2
}

class Mision {
  method cantidadCopas()

  method puedeSerSuperadaPor() = self.tieneEstrategiaSuficiente() || self.tieneDestrezaSuficiente() // ambas misiones analizan la estrategia o destreza del/los personaje/s

  method tieneEstrategiaSuficiente()  // metodo abstracto (cada subclase de mision implementa su comportamiento segun la estrategia del personaje)
  method tieneDestrezaSuficiente()    // metodo abstracto (cada subclase de mision implementa su comportamiento segun la destreza del personaje)

  method realizarMision() {
    if(!self.puedeComenzarMision()) {   // si no puede comenzar la mision, lanzo una excepcion!!
      throw new DomainException(message="Misión no puede comenzar")
    }
    if(self.puedeSerSuperadaPor()) self.recibirCopas() else self.quitarCopas()
  }

  // Podria hacer la validacion de si puede comenzar la validacion en una funcion aparte V2

  method realizarMisionV2() {
    self.validarComienzo()
    self.repartirCopas()
  }

  method validarComienzo() {
    if(!self.puedeComenzarMision()) {   // si no puede comenzar la mision, lanzo una excepcion!!
      throw new DomainException(message="Misión no puede comenzar")
    }
  }

  method repartirCopas() 
  method sumarORestar() = if(self.puedeSerSuperadaPor()) 1 else -1

  // -----------------------------------------------------------------------------------------

  method puedeComenzarMision()    // metodo abstracto (cada subclase de mision tiene requerimientos diferentes en la manera de validar si puede comenzar la mision)
  
  method recibirCopas(){}           // metodo abstracto
  method quitarCopas(){}            // metodo abstracto

}

class MisionIndividual inherits Mision {
  var personaje
  var dificultad 

  override method cantidadCopas() = 2 * dificultad  

// y puede ser superada cuando el personaje tiene estrategia 
//o bien cuando su destreza supera la dificultad de la misión.

  override method tieneEstrategiaSuficiente() = personaje.tieneEstrategia() 
  override method tieneDestrezaSuficiente() = personaje.destreza() > dificultad

  override method puedeComenzarMision() = personaje.copasGanadas() >= 10  

  override method recibirCopas() {personaje.sumarCopas(self.cantidadCopas())}
  override method quitarCopas() {personaje.restarCopas(self.cantidadCopas())}

  // metodo mas general (recibir o quitar copas)
  override method repartirCopas() {personaje.darCopas(self.cantidadCopas() * self.sumarORestar())} // el sumar o restar seria un 1 o -1 (segun si suma po resta la cantidad de copas)

}

class MisionPorEquipo inherits Mision{
  const personajes = []

  override method cantidadCopas() = 50 / personajes.size()

  method mitadParticipantes() = personajes.size() / 2
  method personajesConEstrategia() = personajes.count({x => x.tieneEstrategia()})

// Y pueden ser superadas cuando más de la mitad de los participantes tienen estrategia, 
// o bien, cada uno tiene una destreza mayor a 400.
  override method tieneEstrategiaSuficiente() = self.mitadParticipantes() < self.personajesConEstrategia()  
  override method tieneDestrezaSuficiente() = personajes.all({x => x.destreza() > 400}) 

  override method puedeComenzarMision() = personajes.sum({x => x.copasGanadas()}) >= 60

  // cada uno de los personajes recibe por separado la cantidadCopas totales de la mision
  override method recibirCopas() {personajes.forEach({x => x.sumarCopas(self.cantidadCopas())})}
  override method quitarCopas() {personajes.forEach({x => x.restarCopas(self.cantidadCopas())})}

  // metodo mas general (recibir o quitar copas)
  override method repartirCopas() {personajes.forEach({x => x.darCopas(self.cantidadCopas() * self.sumarORestar())})} // el sumar o restar seria un 1 o -1 (segun si suma po resta la cantidad de copas)

}