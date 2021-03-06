Selector = require('../lib/selector')
parse    = require('postcss/lib/parse')

describe 'Selector', ->
  beforeEach ->
    @selector = new Selector('::selection', ['-moz-', '-ms-'])

  describe 'prefixed()', ->

    it 'adds prefix after non-letters symbols', ->
      @selector.prefixed('-moz-').should.eql('::-moz-selection')

  describe 'check()', ->

    it 'shecks rule selectors', ->
      css = parse('body .selection {}, :::selection {}, body ::selection {}')
      @selector.check(css.rules[0]).should.be.false
      @selector.check(css.rules[1]).should.be.false
      @selector.check(css.rules[2]).should.be.true

  describe 'checker()', ->

    it 'returns function to find prefixed selector', ->
      css = parse(':::-moz-selection {}, body::-moz-selection {}')
      checker = @selector.checker('-moz-')

      checker(css.rules[0]).should.be.false
      checker(css.rules[1]).should.be.true

  describe 'replace()', ->

    it 'should add prefix to selectors', ->
      @selector.replace('body ::selection, input::selection, a', '-ms-').
        should.eql('body ::-ms-selection, input::-ms-selection, a')

  describe 'process()', ->

    it 'adds prefixes', ->
      css = parse('b ::-moz-selection{} b ::selection{}')
      @selector.process(css.rules[1])
      css.toString().should.eql(
        'b ::-moz-selection{} b ::-ms-selection{} b ::selection{}')

    it 'checks parents prefix', ->
      css = parse('@-moz-page { ::selection{} }')
      @selector.process(css.rules[0].rules[0])
      css.toString().should.eql(
        '@-moz-page { ::-moz-selection{} ::selection{} }')
