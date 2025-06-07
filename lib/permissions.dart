import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  String _title = '提示';
  String _message = '需要權限才能繼續使用';
  String _deniedmessage = '偵測到權限被拒，請同意權限才能繼續使用';
  String _permanentlyDeniedmessage = '偵測到權限永久被拒，請至系統設置同意權限才能繼續使用';

  set title(value) => _title = value;
  set message(value) => _message = value;
  set deniedmessage(value) => _deniedmessage = value;
  set permanentlyDeniedmessage(value) => _permanentlyDeniedmessage = value;

  Future<bool> getPermission(
    BuildContext context,
    Permission permission,
  ) async {
    Future<bool> dorequest() async {
      var available = false;
      var status = await _showTip(context);
      if (!status) return false;
      var requestResult = await _requestPermission(permission);
      if (!context.mounted) return false;
      switch (requestResult) {
        case -1:
          _showTipOnPermanentlyDenied(context);
        case 0:
          _showTipOnDenied(context);
        case 1:
          available = true;
      }
      return available;
    }

    var available = false;
    var status = await _checkPermission(permission);
    if (!context.mounted) return false;
    switch (status) {
      case -1:
        _showTipOnPermanentlyDenied(context);
      case 0:
        available = await dorequest();
      case 1:
        available = true;
    }
    return available;
  }

  Future<int> _checkPermission(Permission permission) async {
    var status = await permission.status;
    switch (status) {
      case PermissionStatus.restricted:
        return -1;
      case PermissionStatus.provisional:
        return -1;
      case PermissionStatus.limited:
        return -1;
      case PermissionStatus.permanentlyDenied:
        return -1;
      case PermissionStatus.denied:
        return 0;
      case PermissionStatus.granted:
        return 1;
    }
  }

  Future<int> _requestPermission(Permission permission) async {
    var status = await permission.request();
    switch (status) {
      case PermissionStatus.restricted:
        return -1;
      case PermissionStatus.provisional:
        return -1;
      case PermissionStatus.limited:
        return -1;
      case PermissionStatus.permanentlyDenied:
        return -1;
      case PermissionStatus.denied:
        return 0;
      case PermissionStatus.granted:
        return 1;
    }
  }

  Future<bool> _showTip(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_title),
            content: Text(_message),
            actions: [
              TextButton(
                child: Text('取消'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('確定'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  _showTipOnDenied(BuildContext context) async {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_title),
        content: Text(_deniedmessage),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('確定'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  _showTipOnPermanentlyDenied(BuildContext context) async {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_title),
        content: Text(_permanentlyDeniedmessage),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('確定'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
