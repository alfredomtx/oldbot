#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\libraries\FormData.ahk

/**
* @property object body
* @property bool returnRawResponse
*/
class _AbstractRequest extends _BaseClass
{
    static CLIENT
    static TOKEN

    static WS_HOST := "DISABLED"
    static WS2_HOST := "DISABLED"

    static RETRIES := 3
    static RETRY_DELAY := 1000

    static RESOLVE_TIMEOUT := 0
    static CONNECT_TIMEOUT := 30000
    static SEND_TIMEOUT := 30000
    static RECEIVE_TIMEOUT := 120000

    static TEMP_INI_FILE := A_Temp "\oldbot\temp.ini"

    __Init()
    {
        static validated := ""
        if (validated) {
            return
        }

        validated := true

        classLoaded("JSON", JSON)
        classLoaded("_Logger", _Logger)
        classLoaded("_Ini", _Ini)
    }

    __New()
    {
        if (!this.CLIENT) {
            this.CLIENT := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
        }

        this.body := {}

        this.returnRawResponse := false
        this.requireToken := true
        this.logEnabled := !A_IsCompiled
    }

    /**
    * @return string|object
    */
    execute()
    {
        this.CLIENT.SetTimeouts(this.RESOLVE_TIMEOUT, this.CONNECT_TIMEOUT, this.SEND_TIMEOUT, this.RECEIVE_TIMEOUT) ; before Open()

        url := this.buildUrl()
        this.CLIENT.Open(this.getMethod(), url, false)

        CreateFormData(body, contentType, this.getRequestBody())

        this.setRequestHeaders(contentType)

        try {
            retry(this.send.bind(this, body), this.RETRIES, this.RETRY_DELAY, this.__Class)
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.getRoute())
            throw Exception(txt("Erro na comunicação com o servidor, por favor tente novamente e se problema persistir contate o suporte.", "Server communication error, please try again and if the problem persists contact the support.") "`n`nError: " e.Message)
            throw e
        }

        this.setResponseData()
        this.validateResponse()
        this.handleResponseBody()

        if (this.returnRawResponse) {
            return this.responseBody
        }

        try {
            return JSON.Load(this.responseText)
        } catch e {
            _Logger.exception(e, "Json.Load", this.responseText)
            throw Exception("Error decoding JSON:`n" e.Message "`n`n" this.responseText, "JsonError")
        }
    }

    /**
    * @param ComObjArray body
    * @return void
    */
    send(body)
    {
        this.CLIENT.Send(body)
    }

    /**
    * @return this
    */
    enableLog()
    {
        this.logEnabled := true
        return this
    }

    /**
    * @return this
    */
    disableLog()
    {
        this.logEnabled := false
        return this
    }

    /**
    * @return this
    */
    withoutToken()
    {
        this.requireToken := false
        return this
    }

    /**
    * @return this
    */
    returnRaw()
    {
        this.returnRawResponse := true
        return this
    }

    /**
    * @return string
    */
    buildUrl()
    {
        return Format("https://{1}{2}", this.getHost(), this.getRoute())
    }

    /**
    * @param string msg
    * @return void
    */
    log(msg)
    {
        if (!this.logEnabled) {
            return
        }

        _Logger.log(this.__Class, msg)
    }

    /**
    * @return void
    */
    validateResponse()
    {
        this.validateStatus()
        this.validateResponseText()
        this.validateResponseBody()
    }

    /**
    * @throws
    */
    handleResponseBody()
    {
    }

    /**
    * @throws
    */
    validateStatus()
    {
        switch (true) {
            case this.status == 401:
                throw Exception(this.responseText, "UnauthorizedStatusCode")
            case (SubStr(this.status, 1, 1) != 2):
                throw Exception("Unsuccessful status code: " this.status "`n" this.responseText, "UnsuccessfulStatusCode")
        }
    }

    /**
    * @throws
    */
    validateResponseBody()
    {
    }

    /**
    * @throws
    */
    validateResponseText()
    {
        if (this.responseText = "1") {
            throw Exception("Invalid response from server.")
        }

        if (this.responseText = "") {
            throw Exception("No response from server.")
        }
    }

    throwValidationException(msg)
    {
        throw Exception(msg, "ValidationException")
    }

    ;#Region Getters
    /**
    * @return object
    */
    getBody()
    {
        return this.body
    }

    /**
    * @return object
    */
    getRequestBody()
    {
        return this.getBody()
    }

    /**
    * @return string
    */
    getRoute()
    {
        abstractMethod()
    }

    /**
    * @return string
    */
    getMethod()
    {
        return "POST"
    }

    /**
    * @return string
    */
    getHost()
    {
        return this.WS2_HOST
    }
    ;#Endregion

    ;#Region Setters
    /**
    * @param string contentType
    * @return void
    */
    setRequestHeaders(contentType)
    {
        this.CLIENT.SetRequestHeader("APP", _App.IDENTIFIER)
        this.CLIENT.SetRequestHeader("Accept", "Application/json")
        this.CLIENT.SetRequestHeader("Content-Type", contentType)

        this.log("Request: " this.getMethod() " " this.buildUrl())
        this.log("Body: " serialize(this.getRequestBody()))

        this.log("ContentType: " contentType)

        if (this.requireToken) {
            try {
                _Validation.empty("this.token", this.token)
            } catch {
                throw Exception("Login token not set, please try again that it should work.", "TokenNotSet")
            }

            this.CLIENT.SetRequestHeader("Authorization", "Bearer " this.token)
        }
    }
    /**
    * @param object value
    * @return this
    */
    setBody(value)
    {
        _Validation.isObject("value", value)
        this.body := value

        return this
    }

    /**
    * @return void
    */
    setContentType()
    {
        this.CLIENT.SetRequestHeader("Content-Type", "application/json")
    }

    /**
    * @return void
    */
    setResponseData()
    {
        this.status := this.CLIENT.Status
        this.responseText := this.CLIENT.ResponseText
        this.responseBody := this.CLIENT.ResponseBody

        this.log("Status: " this.status)
        this.log("ResponseText: " this.responseText)
        this.log("ResponseBody: " this.responseBody)
    }

    /**
    * @param string token
    * @return this
    */
    setToken(token)
    {
        _Validation.empty("token", token)
        this.token := token

        return this
    }
    ;#Endregion
}