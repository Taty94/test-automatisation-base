@REQ_MARVEL-101 @HU101 @character_management @marvel_characters_api @Agente2 @E2 @iniciativa_marvel
Feature: MARVEL-101 Gestión de personajes de Marvel (microservicio para gestionar personajes Marvel)
  Background:
    * url port_marvel_characters_api
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def generarHeaders =
      """
      function() {
        return {
          "Content-Type": "application/json"
        };
      }
      """
    * def headers = generarHeaders()
    * headers headers

  @id:1 @obtenerPersonajes @solicitudExitosa200
  Scenario: T-API-MARVEL-101-CA01-Obtener todos los personajes 200 - karate
    * path '/characters'
    When method GET
    Then status 200
    And match response != null
    And match response == '#array'
  
  @id:2 @crearPersonaje @solicitudExitosa201
  Scenario: T-API-MARVEL-101-CA04-Crear personaje exitoso 201 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * set jsonData.name = jsonData.name + ' ' + timestamp()
    * path '/characters'
    And request jsonData
    When method POST
    Then status 201
    And match response.id == '#notnull'
    And match response.name contains 'Super Girl'
  
  @id:3 @obtenerPersonajePorId @solicitudExitosa200
  Scenario: T-API-MARVEL-101-CA02-Obtener personaje por ID exitoso 200 - karate
    # Primero creamos un personaje para asegurarnos de tener algo para eliminar
    * def jsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * set jsonData.name = 'Created Test Character ' + timestamp()
    * path '/characters'
    And request jsonData
    When method POST
    Then status 201
    * def createdId = response.id
    * print 'ID del personaje creado:', createdId
    * path '/characters/' + createdId
    * print 'Consultando personaje con ID:', createdId
    When method GET
    Then status 200
    And match response.id == createdId

  @id:4 @obtenerPersonajePorId @noExiste404
  Scenario: T-API-MARVEL-101-CA03-Obtener personaje por ID no existente 404 - karate
    * path '/characters/999'
    When method GET
    Then status 404
    And match response.error == 'Character not found'
    And match response == { error: '#notnull' }

  @id:5 @crearPersonaje @nombreDuplicado400
  Scenario: T-API-MARVEL-101-CA05-Crear personaje con nombre duplicado 400 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_duplicate_character.json')
    * path '/characters'
    And request jsonData
    When method POST
    Then status 400
    And match response.error == 'Character name already exists'
    And match response contains { error: '#notnull' }

  @id:6 @crearPersonaje @camposRequeridosVacios400
  Scenario: T-API-MARVEL-101-CA06-Crear personaje con campos requeridos vacíos 400 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_invalid_character.json')
    * path '/characters'
    And request jsonData
    When method POST
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
  
  @id:7 @actualizarPersonaje @solicitudExitosa200
  Scenario: T-API-MARVEL-101-CA07-Actualizar personaje exitoso 200 - karate
    # Primero creamos un personaje para asegurarnos de tener algo para actualizar
    * def createJsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * set createJsonData.name = 'Update Test Character ' + timestamp()
    * path '/characters'
    And request createJsonData
    When method POST
    Then status 201
    * def characterIdToUpdate = response.id
    # Ahora actualizamos el personaje que acabamos de crear
    * def jsonData = read('classpath:data/marvel_characters_api/request_update_character.json')
    * path '/characters/' + characterIdToUpdate
    And request jsonData
    When method PUT
    Then status 200
    And match response.id == characterIdToUpdate

  @id:8 @actualizarPersonaje @noExiste404
  Scenario: T-API-MARVEL-101-CA08-Actualizar personaje no existente 404 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_update_character.json')
    * path '/characters/999'
    And request jsonData
    When method PUT
    Then status 404
    And match response.error == 'Character not found'
    And match response contains { error: '#notnull' }
  
  @id:9 @eliminarPersonaje @solicitudExitosa204
  Scenario: T-API-MARVEL-101-CA09-Eliminar personaje exitoso 204 - karate
    # Primero creamos un personaje para asegurarnos de tener algo para eliminar
    * def jsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * set jsonData.name = 'Delete Test Character ' + timestamp()
    * path '/characters'
    And request jsonData
    When method POST
    Then status 201
    * def characterIdToDelete = response.id
    
    # Ahora eliminamos el personaje que acabamos de crear
    * path '/characters/' + characterIdToDelete
    When method DELETE
    Then status 204
    And match response == ''
    And match responseBytes == '#[0]'

  @id:10 @eliminarPersonaje @noExiste404
  Scenario: T-API-MARVEL-101-CA10-Eliminar personaje no existente 404 - karate
    * path '/characters/999'
    When method DELETE
    Then status 404
    And match response.error == 'Character not found'
    And match response contains { error: '#notnull' }

  @id:11 @serverError @errorServicio500
  Scenario: T-API-MARVEL-101-CA11-Error interno del servidor 500 - karate
    * path '/characters/error'
    When method GET
    Then status 500
    And match response.error == 'Internal server error'


 