component extends="oauth2" accessors="true" {

	property name="client_id" type="string";
	property name="client_secret" type="string";
	property name="authEndpoint" type="string";
	property name="accessTokenEndpoint" type="string";
	property name="redirect_uri" type="string";
	
	/**
	* I return an initialized xero object instance.
	* @client_id The client ID for your application.
	* @client_secret The client secret for your application.
	* @authEndpoint The URL endpoint that handles the authorisation.
	* @accessTokenEndpoint The URL endpoint that handles retrieving the access token.
	* @redirect_uri The URL to redirect the user back to following authentication.
	**/
	public xero function init(
		required string client_id, 
		required string client_secret, 
		required string authEndpoint = 'https://login.xero.com/identity/connect/authorize', 
		required string accessTokenEndpoint = 'https://identity.xero.com/connect/token',
		required string redirect_uri
	)
	{
		super.init(
			client_id           = arguments.client_id, 
			client_secret       = arguments.client_secret, 
			authEndpoint        = arguments.authEndpoint, 
			accessTokenEndpoint = arguments.accessTokenEndpoint, 
			redirect_uri        = arguments.redirect_uri
		);
		return this;
	}

	/**
	* I return the URL as a string which we use to redirect the user for authentication.
	* @scope An optional array of values to pass through for scope access. If not provided, scope defaults to an empty list for users that have not authorized any scopes for the application. For users who have authorized scopes for the application, the user won't be shown the OAuth authorization page with the list of scopes. Instead, this step of the flow will automatically complete with the set of scopes the user has authorized for the application. For example, if a user has already performed the web flow twice and has authorized one token with user scope and another token with repo scope, a third web flow that does not provide a scope will receive a token with user and repo scope.
	* @state A unique string value of your choice that is hard to guess. Used to prevent CSRF.
	* @allow_signup Whether or not unauthenticated users will be offered an option to sign up for Xero during the OAuth flow. The default is true. Use false in the case that a policy prohibits signups.

Set the parameter value to an email address or sub identifier.
	**/
	public string function buildRedirectToAuthURL(
		required array scope,
		required string state,
    string response_type="code"
	){
		var sParams = {
      'response_type' = arguments.response_type,
			'scope'         = arrayToList( arguments.scope, ' ' ),
      'state'         = arguments.state,
      'allow_signup'  = true
		};
		return super.buildRedirectToAuthURL( sParams );
	}

	/**
	* I make the HTTP request to obtain the access token.
	* @code The code returned from the authentication request.
	**/
	public struct function makeAccessTokenRequest(
		required string code
	){
		var aFormFields = [ 
			{
				'name'  = 'grant_type',
				'value' = 'authorization_code'
			}
    ];
    var aHeaders = [
      {
        'name' = 'authorization',
        'value' = getAuthHeader()
      }
    ];
		return super.makeAccessTokenRequest(
			code = arguments.code,
      formfields = aFormFields,
      headers = aHeaders
		);
  }
  
  /**
   * I make an HTTP request to refresh an access token
   */
  public struct function makeRefreshTokenRequest(
    required string refresh_token
  ){
    var aHeaders = [
      {
        'name' = 'authorization',
        'value' = getAuthHeader()
      }
    ];
    return super.makeRefreshTokenRequest(
      refresh_token = arguments.refresh_token,
      headers = aHeaders
		);
  }

  private string function getAuthHeader(
  ){
    return "Basic " & toBase64(this.client_id & ":" & this.client_secret);
  }

}