describe 'Running calculable()', ->
  $dom = null

  beforeEach ->
    $dom = $(
      """
      <div id='calculatable'>
        <table>
        </table>
      </div>
      """
    )

  it 'should be applicable to generic DOM elements', ->
    expect $dom.data('calculatable') instanceof Calculatable
      .toBeFalsy()

  it 'should create a new instance the first time', ->
    $dom.calculatable()
    expect $dom.data('calculatable') instanceof Calculatable
      .toBeTruthy()

  it 'should not override preexisting Calculatables', ->
    first = $dom.calculatable()
    second = $dom.calculatable()
    expect first
      .toEqual second
