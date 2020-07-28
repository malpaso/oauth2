component extends='testbox.system.BaseSpec'{
	
	/*********************************** BDD SUITES ***********************************/
	
	function run(){

		describe( 'Xero Component Suite', function(){
			
			variables.thisProvider = 'xero';
			variables.sProviderData = {};

			include 'providerData.properties.cfm';

			if( structKeyExists( variables.providerInfo, variables.thisProvider ) ){
				variables.sProviderData = variables.providerInfo[ variables.thisProvider ];
			} else {
				variables.sProviderData = variables.providerInfo[ 'default' ];
			}

			var clientId     = variables.sProviderData[ 'clientId' ];
			var clientSecret = variables.sProviderData[ 'clientSecret' ];
			var redirect_uri = variables.sProviderData[ 'redirect_uri' ];

			var oXero = new xero(
				client_id           = clientId,
				client_secret       = clientSecret,
				redirect_uri        = redirect_uri
			);
			
			it( 'should return the correct object', function(){

				expect( oXero ).toBeInstanceOf( 'xero' );
				expect( oXero ).toBeTypeOf( 'component' );

			});

			it( 'should have the correct properties', function() {

				var sMemento = oXero.getMemento();

				expect( sMemento ).toBeStruct().toHaveLength( 5 );

				expect( sMemento ).toHaveKey( 'client_id' );
				expect( sMemento ).toHaveKey( 'client_secret' );
				expect( sMemento ).toHaveKey( 'authEndpoint' );
				expect( sMemento ).toHaveKey( 'accessTokenEndpoint' );
				expect( sMemento ).toHaveKey( 'redirect_uri' );

				expect( sMemento[ 'client_id' ] ).toBeString().toBe( clientId );
				expect( sMemento[ 'client_secret' ] ).toBeString().toBe( clientSecret );
				expect( sMemento[ 'redirect_uri' ] ).toBeString().toBe( redirect_uri );

			} );

			it( 'should have the correct methods', function() {

				expect( oXero ).toHaveKey( 'init' );
				expect( oXero ).toHaveKey( 'buildRedirectToAuthURL' );
				expect( oXero ).toHaveKey( 'makeAccessTokenRequest' );
				expect( oXero ).toHaveKey( 'buildParamString' );
				expect( oXero ).toHaveKey( 'getMemento' );

			} );

			it( 'should return a string when calling the `buildRedirectToAuthURL` method', function() {

				var strState = createUUID();
				var aScope = [
					'repo',
					'user'
				];
				var strURL = oXero.buildRedirectToAuthURL(
					scope = aScope,
					state = strState
				);

				expect( strURL ).toBeString();

				var arrData = listToArray( strURL, '&?' );

				expect( arrData ).toHaveLength( 7 );
				expect( arrData[ 1 ] )
					.toBeString()
					.toBe( oXero.getAuthEndpoint() );

				var stuParams = {};
				for( var i = 2; i <= arrayLen( arrData ); i++ ){
					structInsert( stuParams, listGetAt( arrData[ i ], 1, '=' ), listGetAt( arrData[ i ], 2, '=' ) );
				}

				expect( stuParams[ 'client_id' ] ).toBeString().toBe( clientId );
				expect( stuParams[ 'redirect_uri' ] ).toBeString().toBe( oXero.getRedirect_URI() );
				expect( stuParams[ 'state' ] ).toBeString().toBe( strState );
				expect( stuParams[ 'scope' ] ).toBeString().toBe( 'repo user' );
				expect( stuParams[ 'allow_signup' ] ).toBeString().toBe( 'true' );

			} );

		} );

	}
	
}
