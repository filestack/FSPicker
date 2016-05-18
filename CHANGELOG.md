## 0.1.5-beta (2016-05-18)

### Fixed

- ```FSGridViewController``` crash on uploading multiple files.

## 0.1.4-beta (2016-05-17)

### Fixed:

- ```FSSearchViewController``` crash on uploading multiple files.

## 0.1.3-beta (2016-05-12)

### Fixed:

- Missing FSPicker.h source file added to pod.

## 0.1.2-beta (2016-05-11)

### Added:

- ```defaultToFrontCamera``` configuration option.
- ```selectMultiple``` option implementation.
- Small delay before dismissing upload progress view.

### Fixed:

- ```picker:didFinishedPickingMediaWithBlobs:``` should be now called only once, after finished upload.
- Web Search is now correctly returning results (if any present).
- FSPickerDelegate methods messages are now dispatched to main thread.

## 0.1.1-beta (2016-05-06)

### Initial beta release
