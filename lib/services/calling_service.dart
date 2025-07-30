import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_models.dart';

class CallingService {
  static CallingService? _instance;
  static CallingService get instance =>
      _instance ??= CallingService._internal();
  CallingService._internal();

  // Call state
  bool _isInCall = false;
  String? _currentCallId;
  String? _remoteUserId;
  CallType _currentCallType = CallType.audio;

  // Event streams
  final StreamController<String> _callStateController =
      StreamController<String>.broadcast();
  final StreamController<bool> _callQualityController =
      StreamController<bool>.broadcast();

  // Getters
  Stream<String> get callState => _callStateController.stream;
  Stream<bool> get callQuality => _callQualityController.stream;

  bool get isInCall => _isInCall;
  String? get currentCallId => _currentCallId;
  String? get remoteUserId => _remoteUserId;
  CallType get currentCallType => _currentCallType;

  // Initialize calling service
  Future<void> initialize() async {
    try {
      // Request permissions
      await _requestPermissions();

      // Simulate connection to signaling server
      await Future.delayed(const Duration(seconds: 1));
      _callStateController.add('connected');

      print('Calling service initialized successfully');
    } catch (e) {
      print('Error initializing calling service: $e');
      rethrow;
    }
  }

  // Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus != PermissionStatus.granted ||
        microphoneStatus != PermissionStatus.granted) {
      throw Exception(
          'Camera and microphone permissions are required for calls');
    }
  }

  // Start a call
  Future<void> startCall(
      String callId, String remoteUserId, CallType callType) async {
    try {
      _currentCallId = callId;
      _remoteUserId = remoteUserId;
      _currentCallType = callType;
      _isInCall = true;

      // Simulate call setup
      await Future.delayed(const Duration(seconds: 2));
      _callStateController.add('call_started');

      // Simulate call quality monitoring
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_isInCall) {
          _callQualityController.add(true); // Good quality
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      print('Error starting call: $e');
      rethrow;
    }
  }

  // Answer a call
  Future<void> answerCall(
      String callId, String remoteUserId, CallType callType) async {
    try {
      _currentCallId = callId;
      _remoteUserId = remoteUserId;
      _currentCallType = callType;
      _isInCall = true;

      // Simulate call answer
      await Future.delayed(const Duration(seconds: 1));
      _callStateController.add('call_answered');
    } catch (e) {
      print('Error answering call: $e');
      rethrow;
    }
  }

  // End call
  Future<void> endCall() async {
    try {
      _isInCall = false;
      _callStateController.add('call_ended');

      // Clear call state
      _currentCallId = null;
      _remoteUserId = null;
    } catch (e) {
      print('Error ending call: $e');
      rethrow;
    }
  }

  // Toggle camera
  Future<void> toggleCamera() async {
    if (_currentCallType == CallType.video) {
      _callStateController.add('camera_toggled');
    }
  }

  // Toggle microphone
  Future<void> toggleMicrophone() async {
    _callStateController.add('microphone_toggled');
  }

  // Switch camera
  Future<void> switchCamera() async {
    if (_currentCallType == CallType.video) {
      _callStateController.add('camera_switched');
    }
  }

  // Get call statistics
  Map<String, dynamic> getCallStats() {
    return {
      'callDuration':
          _isInCall ? DateTime.now().difference(DateTime.now()).inSeconds : 0,
      'callQuality': 'Good',
      'packetLoss': '0%',
      'latency': '50ms',
    };
  }

  // Dispose resources
  void dispose() {
    endCall();
    _callStateController.close();
    _callQualityController.close();
  }
}

enum CallType { audio, video }
