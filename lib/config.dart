
const defaultFileDirectory = 'files';

const fileDirectories = {
  'docx': 'docs',
  'xlsx': 'sheets',
  'pptx': 'slides',
};

final staticDocDirectories = [
  ...fileDirectories.values,
  defaultFileDirectory,
];
