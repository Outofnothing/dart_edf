import 'package:edf_lib/edf_field.dart';

class HeaderTimes {
  // Fixed length header items
  static final EdfField version = EdfField('Version', 8);
  static final EdfField patientID = EdfField('PatientID', 80);
  static final EdfField recordID = EdfField('RecordID', 80);
  static final EdfField recordingStartDate = EdfField('StartDate', 8);
  static final EdfField recordingStartTime = EdfField('StartTime', 8);
  static final EdfField sizeInBytes = EdfField('NumberOfBytesInHeader', 8);
  static final EdfField reserved = EdfField('Reserved', 44);
  static final EdfField numberOfDataRecords =
      EdfField('NumberOfDataRecords', 8);
  static final EdfField recordDurationInSeconds =
      EdfField('DurationOfDataRecord', 8);
  static final EdfField numberOfSignalsInRecord =
      EdfField('NumberOfSignals', 4);

  // Variable size signal header items
  static final EdfField label = EdfField('Labels', 16);
  static final EdfField transducerType = EdfField('TransducerType', 80);
  static final EdfField physicalDimension = EdfField('PhysicalDimension', 8);
  static final EdfField physicalMinimum = EdfField('PhysicalMinimum', 8);
  static final EdfField physicalMaximum = EdfField('PhysicalMaximum', 8);
  static final EdfField digitalMinimum = EdfField('DigitalMinimum', 8);
  static final EdfField digitalMaximum = EdfField('DigitalMaximum', 8);
  static final EdfField prefiltering = EdfField('Prefiltering', 80);
  static final EdfField numberOfSamplesInDataRecord =
      EdfField('NumberOfSamplesInDataRecord', 8);
  static final EdfField signalsReserved = EdfField('SignalsReserved', 32);
}
