# react-native-aws-s3

Background File Upload

## Installation

```sh
npm install react-native-aws-s3
```

## Usage

```js
import { uploadFile, getUploadStatus, cancelUpload } from 'react-native-aws-s3';

// ...

 //Generic method for both iOS and Android
    uploadFile(
      workId,
      filePath,
      s3Key,
      bucketName,
      accessKey,
      secreteKey,
      region
    )
      .then((result: any) => {
        const { workId, status } = result;
        console.log(`WorkId : ${workId} Status : ${status}`);
      })
      .catch((error: any) => {
        console.log(error);
        console.log('Error Code:', error.code);
        console.log('Error Message:', error.message);
        console.log('User Info', error.userInfo);
      });
```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
