class _MountedLifeBarArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "mountedLifeBarArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_MountedLifeBarArea.INSTANCE) {
            return _MountedLifeBarArea.INSTANCE
        }

        base.__New(this)

        _MountedLifeBarArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        gameWindowArea := new _GameWindowArea()
        charPosition := new _CharPosition()



        ; Define the part and the whole
        Part := 4
        Whole := SQM_SIZE

        ; Calculate the percentage
        Percentage := (Part / Whole) * 100

        ; Display the percentage
        MsgBox The percentage is: %Percentage% of %SQM_SIZE%

        ; Define the known values
        A := Percentage
        B := 4
        C := 100

        ; Calculate the unknown value X using the Rule of Three
        X := (B * C) / A

        ; Display the result
        MsgBox The unknown value X is: %X%



        barWidth := 34
        barHeight := 10

        ; Define your input and output ranges
        InputMin := 0
        InputMax := 100
        OutputMin := 0
        OutputMax := 255

        ; Input value you want to map
        InputValue := 99

        ; Calculate the mapped value
        MappedValue := (InputValue - InputMin) / (InputMax - InputMin) * (OutputMax - OutputMin) + OutputMin

        ; Display the mapped value
        MsgBox MappedValue: %MappedValue%

        c1 := gameWindowArea.getC1().clone()
            .addX(SQM_SIZE * 7)
            .addY(SQM_SIZE * 5)
            .subY(minY)
        ; .subY(SQM_SIZE / 5)
        c2 := c1.clone()
            .addX(SQM_SIZE)
            .addY(SQM_SIZE)
        ; .addX(barWidth)
        ; .addX(barWidth + 4)
        ; .addY(barHeight + 4)
        ; .addY(barHeight)

        coordinates := new _Coordinates(c1, c2)
            .debug()
        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _MountedLifeBarArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _MountedLifeBarArea.INITIALIZED := true
    }
}