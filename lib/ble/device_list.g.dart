// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_list.dart';

// **************************************************************************
// FunctionalDataGenerator
// **************************************************************************

abstract class $ScanningList {
  const $ScanningList();

  String get deviceId;
  // Connectable get connectableStatus;
  // DeviceConnectionState get connectionStatus;
  BleDeviceConnector get deviceConnector;
  Future<List<DiscoveredService>> Function() get discoverServices;

  ScanningList copyWith({
    String? deviceId,
    // Connectable? connectableStatus,
    // DeviceConnectionState? connectionStatus,
    BleDeviceConnector? deviceConnector,
    Future<List<DiscoveredService>> Function()? discoverServices,
  }) =>
      ScanningList(
        deviceId: deviceId ?? this.deviceId,
        // connectableStatus: connectableStatus ?? this.connectableStatus,
        // connectionStatus: connectionStatus ?? this.connectionStatus,
        deviceConnector: deviceConnector ?? this.deviceConnector,
        discoverServices: discoverServices ?? this.discoverServices,
      );

  ScanningList copyUsing(
      void Function(DeviceList$Change change) mutator) {
    final change = DeviceList$Change._(
      deviceId,
      // this.connectableStatus,
      // this.connectionStatus,
      deviceConnector,
      discoverServices,
    );
    mutator(change);
    return ScanningList(
      deviceId: change.deviceId,
      // connectableStatus: change.connectableStatus,
      // connectionStatus: change.connectionStatus,
      deviceConnector: change.deviceConnector,
      discoverServices: change.discoverServices,
    );
  }

  @override
  String toString() =>
      // "DeviceList(deviceId: $deviceId, connectableStatus: $connectableStatus, connectionStatus: $connectionStatus, deviceConnector: $deviceConnector, discoverServices: $discoverServices)";
      "DeviceList(deviceId: $deviceId, deviceConnector: $deviceConnector, discoverServices: $discoverServices)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is ScanningList &&
          other.runtimeType == runtimeType &&
          deviceId == other.deviceId &&
          // connectableStatus == other.connectableStatus &&
          // connectionStatus == other.connectionStatus &&
          deviceConnector == other.deviceConnector &&
          const Ignore().equals(discoverServices, other.discoverServices);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    var result = 17;
    result = 37 * result + deviceId.hashCode;
    // result = 37 * result + connectableStatus.hashCode;
    // result = 37 * result + connectionStatus.hashCode;
    result = 37 * result + deviceConnector.hashCode;
    result = 37 * result + const Ignore().hash(discoverServices);
    return result;
  }
}

class DeviceList$Change {
  DeviceList$Change._(
      this.deviceId,
      // this.connectableStatus,
      // this.connectionStatus,
      this.deviceConnector,
      this.discoverServices,
      );

  String deviceId;
  // Connectable connectableStatus;
  // DeviceConnectionState connectionStatus;
  BleDeviceConnector deviceConnector;
  Future<List<DiscoveredService>> Function() discoverServices;
}

// ignore: avoid_classes_with_only_static_members
class DeviceList$ {
  static final deviceId = Lens<ScanningList, String>(
        (deviceIdContainer) => deviceIdContainer.deviceId,
        (deviceIdContainer, deviceId) =>
        deviceIdContainer.copyWith(deviceId: deviceId),
  );
/*
  static final connectableStatus =
  Lens<DeviceList, Connectable>(
        (connectableStatusContainer) =>
    connectableStatusContainer.connectableStatus,
        (connectableStatusContainer, connectableStatus) =>
        connectableStatusContainer.copyWith(
            connectableStatus: connectableStatus),
  );

  static final connectionStatus =
  Lens<DeviceList, DeviceConnectionState>(
        (connectionStatusContainer) => connectionStatusContainer.connectionStatus,
        (connectionStatusContainer, connectionStatus) =>
        connectionStatusContainer.copyWith(connectionStatus: connectionStatus),
  );
*/
  static final deviceConnector =
  Lens<ScanningList, BleDeviceConnector>(
        (deviceConnectorContainer) => deviceConnectorContainer.deviceConnector,
        (deviceConnectorContainer, deviceConnector) =>
        deviceConnectorContainer.copyWith(deviceConnector: deviceConnector),
  );

  static final discoverServices = Lens<ScanningList,
      Future<List<DiscoveredService>> Function()>(
        (discoverServicesContainer) => discoverServicesContainer.discoverServices,
        (discoverServicesContainer, discoverServices) =>
        discoverServicesContainer.copyWith(discoverServices: discoverServices),
  );
}