import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import MonacoEditor from 'react-monaco-editor';

const selectionBlockStyle = {
  position: 'absolute',
  left: 0,
  right: 0,
  top: 0,
  bottom: 0,
};

class Editor extends PureComponent {
  static propTypes = {
    value: PropTypes.string,
    name: PropTypes.string.isRequired,
    editable: PropTypes.bool,
    syntax: PropTypes.string,
    onChange: PropTypes.func,
    allowCopy: PropTypes.bool,
    keyboardHandler: PropTypes.string,
  }

  static defaultProps = {
    value: '',
    editable: false,
    onChange: null,
    syntax: 'javascript',
    allowCopy: true,
    keyboardHandler: '',
  }

  render() {
    const {
      value,
      name,
      editable,
      syntax,
      onChange,
      allowCopy,
      keyboardHandler,
      editorHeight,
    } = this.props;

    // FIXME: move here and apply mapping object
    const mappedSyntax = syntax === 'js' ? 'javascript' : syntax;

    const options = {
      fontSize: 16,
      scrollBeyondLastLine: false,
      selectOnLineNumbers: true,
      // automaticLayout: true,
      minimap: {
        enabled: true,
      },
    };

    return (
      <div className="my-2" style={{ position: 'relative' }}>

        <MonacoEditor
          height={editorHeight}
          theme="vs-dark"
          options={options}
          language={console.log(mappedSyntax) || mappedSyntax}
          value={value}
          onChange={onChange}
        />
      </div>
    );
  }
}

export default Editor;
