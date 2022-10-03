
const defaultFileDirectory = 'files';

const fileDirectories = {
  'docx': 'docs',
  'xlsx': 'sheets',
  'pptx': 'slides',
};

const fillFormsDocs = [".oform", ".docx"];

final staticDocDirectories = [
  ...fileDirectories.values,
  defaultFileDirectory,
];

const historyDir = 'history';

const webTypes = ['desktop', 'mobile', 'embedded'];

const fileTypes = {
  'docx': 'word',
  'xlsx': 'cell',
  'pptx': 'slide',
};

const fileImages = {
  'word': 'file_docx.svg',
  'cell': 'file_xlsx.svg',
  'slide': 'file_pptx.svg',
};
