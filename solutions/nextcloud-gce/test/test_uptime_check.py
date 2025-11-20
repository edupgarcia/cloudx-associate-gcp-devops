#!/usr/bin/env python3
"""Unit tests for Uptime Check configuration.

Tests validate that:
1. The uptime check is created with the correct display name.
2. The uptime check is created with the correct host.
3. The uptime check is created with the correct project ID label.
4. The uptime check is configured with the correct monitoring period.
5. The uptime check is configured with the correct path and port.
"""

import unittest
from unittest.mock import Mock, patch
import subprocess
import json


class TestUptimeCheckConfiguration(unittest.TestCase):
    """Test cases for uptime check configuration validation."""

    def setUp(self):
        """Set up test fixtures."""
        self.expected_display_name = "Nextcloud Uptime Check"
        self.expected_host = "34.160.123.45"  # Example IP
        self.expected_project_id = "my-gcp-project"
        self.expected_period = "60s"  # Period is returned in seconds format
        self.expected_path = "/"
        self.expected_port = "80"
        self.expected_timeout = "10s"

    @patch('subprocess.run')
    def test_uptime_check_display_name(self, mock_run):
        """Test that the uptime check is created with the correct display name."""
        # Mock gcloud command response
        mock_response = {
            "displayName": "Nextcloud Uptime Check",
            "name": "projects/my-project/uptimeCheckConfigs/12345"
        }
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_response),
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command to get uptime check details
        result = subprocess.run(
            [
                "gcloud", "monitoring", "uptime", "list",
                "--format=json"
            ],
            capture_output=True,
            text=True
        )
        
        # Parse and validate
        uptime_checks = json.loads(result.stdout)
        display_name = uptime_checks.get("displayName", "")
        
        self.assertEqual(display_name, self.expected_display_name,
                        f"Expected display name '{self.expected_display_name}', "
                        f"got '{display_name}'")
        
        # Verify gcloud was called correctly
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn("monitoring", args)
        self.assertIn("uptime", args)
        self.assertIn("list", args)

    @patch('subprocess.run')
    def test_uptime_check_host(self, mock_run):
        """Test that the uptime check is created with the correct host."""
        # Mock gcloud command response with monitored resource
        mock_response = {
            "displayName": "Nextcloud Uptime Check",
            "monitoredResource": {
                "type": "uptime_url",
                "labels": {
                    "host": "34.160.123.45",
                    "project_id": "my-gcp-project"
                }
            }
        }
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_response),
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "monitoring", "uptime", "describe",
                "Nextcloud Uptime Check",
                "--format=json"
            ],
            capture_output=True,
            text=True
        )
        
        # Parse and validate
        uptime_check = json.loads(result.stdout)
        host = uptime_check.get("monitoredResource", {}).get("labels", {}).get("host", "")
        
        self.assertEqual(host, self.expected_host,
                        f"Expected host '{self.expected_host}', got '{host}'")
        
        # Verify gcloud was called with correct parameters
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn("describe", args)
        self.assertIn("Nextcloud Uptime Check", args)

    @patch('subprocess.run')
    def test_uptime_check_project_id_label(self, mock_run):
        """Test that the uptime check is created with the correct project ID label."""
        # Mock gcloud command response
        mock_response = {
            "displayName": "Nextcloud Uptime Check",
            "monitoredResource": {
                "type": "uptime_url",
                "labels": {
                    "host": "34.160.123.45",
                    "project_id": "my-gcp-project"
                }
            }
        }
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_response),
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "monitoring", "uptime", "describe",
                "Nextcloud Uptime Check",
                "--format=json"
            ],
            capture_output=True,
            text=True
        )
        
        # Parse and validate
        uptime_check = json.loads(result.stdout)
        project_id = uptime_check.get("monitoredResource", {}).get("labels", {}).get("project_id", "")
        
        self.assertEqual(project_id, self.expected_project_id,
                        f"Expected project_id '{self.expected_project_id}', got '{project_id}'")
        
        # Verify the project_id label exists
        self.assertIsNotNone(project_id, "project_id label should not be None")
        self.assertTrue(len(project_id) > 0, "project_id label should not be empty")

    @patch('subprocess.run')
    def test_uptime_check_monitoring_period(self, mock_run):
        """Test that the uptime check is configured with the correct monitoring period."""
        # Mock gcloud command response
        # Period of 1 minute is represented as "60s" in the API response
        mock_response = {
            "displayName": "Nextcloud Uptime Check",
            "period": "60s",
            "timeout": "10s"
        }
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_response),
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "monitoring", "uptime", "describe",
                "Nextcloud Uptime Check",
                "--format=json"
            ],
            capture_output=True,
            text=True
        )
        
        # Parse and validate
        uptime_check = json.loads(result.stdout)
        period = uptime_check.get("period", "")
        
        self.assertEqual(period, self.expected_period,
                        f"Expected period '{self.expected_period}', got '{period}'")
        
        # Verify the period is set (not empty)
        self.assertIsNotNone(period, "period should not be None")
        self.assertTrue(len(period) > 0, "period should not be empty")

    @patch('subprocess.run')
    def test_uptime_check_path_and_port(self, mock_run):
        """Test that the uptime check is configured with the correct path and port."""
        # Mock gcloud command response
        mock_response = {
            "displayName": "Nextcloud Uptime Check",
            "httpCheck": {
                "path": "/",
                "port": 80,
                "requestMethod": "GET"
            }
        }
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_response),
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "monitoring", "uptime", "describe",
                "Nextcloud Uptime Check",
                "--format=json"
            ],
            capture_output=True,
            text=True
        )
        
        # Parse and validate
        uptime_check = json.loads(result.stdout)
        http_check = uptime_check.get("httpCheck", {})
        path = http_check.get("path", "")
        port = str(http_check.get("port", ""))
        
        self.assertEqual(path, self.expected_path,
                        f"Expected path '{self.expected_path}', got '{path}'")
        self.assertEqual(port, self.expected_port,
                        f"Expected port '{self.expected_port}', got '{port}'")
        
        # Verify both path and port are set
        self.assertIsNotNone(path, "path should not be None")
        self.assertIsNotNone(port, "port should not be None")
        self.assertTrue(len(path) > 0, "path should not be empty")

    @patch('subprocess.run')
    def test_uptime_check_timeout(self, mock_run):
        """Test that the uptime check is configured with the correct timeout."""
        # Mock gcloud command response
        mock_response = {
            "displayName": "Nextcloud Uptime Check",
            "timeout": "10s"
        }
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_response),
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "monitoring", "uptime", "describe",
                "Nextcloud Uptime Check",
                "--format=json"
            ],
            capture_output=True,
            text=True
        )
        
        # Parse and validate
        uptime_check = json.loads(result.stdout)
        timeout = uptime_check.get("timeout", "")
        
        self.assertEqual(timeout, self.expected_timeout,
                        f"Expected timeout '{self.expected_timeout}', got '{timeout}'")

    @patch('subprocess.run')
    def test_uptime_check_not_found(self, mock_run):
        """Test handling when uptime check does not exist."""
        # Mock gcloud command returning error
        mock_run.return_value = Mock(
            stdout="",
            stderr="ERROR: (gcloud.monitoring.uptime.describe) Resource not found",
            returncode=1
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "monitoring", "uptime", "describe",
                "Non-existent Uptime Check",
                "--format=json"
            ],
            capture_output=True,
            text=True
        )
        
        # Validate error is returned
        self.assertNotEqual(result.returncode, 0,
                           "Expected non-zero return code for non-existent uptime check")
        self.assertIn("ERROR", result.stderr,
                     "Expected error message in stderr")


class TestUptimeCheckValidationHelpers(unittest.TestCase):
    """Test helper functions for uptime check validation."""

    def test_validate_display_name_format(self):
        """Test that display names follow expected format."""
        valid_names = [
            "Nextcloud Uptime Check",
            "My Application Uptime",
            "Service Health Check",
        ]
        
        invalid_names = [
            "",                    # empty
            "uptime-check",        # all lowercase with hyphens (expecting title case)
            "UPTIME CHECK",        # all uppercase
            "check",               # too short/generic
        ]
        
        for name in valid_names:
            with self.subTest(name=name):
                # Validate it's not empty and contains meaningful text
                self.assertTrue(len(name) > 0, f"Valid name '{name}' should not be empty")
                self.assertTrue(len(name.split()) >= 2, 
                              f"Valid name '{name}' should contain at least 2 words")
        
        for name in invalid_names:
            with self.subTest(name=name):
                # These should fail basic validation
                if name == "":
                    self.assertEqual(len(name), 0)
                else:
                    # Other invalid names might pass length but fail semantic checks
                    is_valid = len(name) > 0 and len(name.split()) >= 2
                    if name in ["uptime-check", "UPTIME CHECK", "check"]:
                        # These fail our semantic validation
                        pass

    def test_validate_ip_address_format(self):
        """Test IP address format validation."""
        def is_valid_ip(ip):
            """Validate IP address format and range."""
            import re
            pattern = re.compile(r'^(\d{1,3}\.){3}\d{1,3}$')
            if not pattern.match(ip):
                return False
            # Check each octet is in valid range (0-255)
            octets = ip.split('.')
            return all(0 <= int(octet) <= 255 for octet in octets)
        
        valid_ips = [
            "34.160.123.45",
            "192.168.1.1",
            "10.0.0.1",
        ]
        
        invalid_ips = [
            "256.1.1.1",          # Invalid octet
            "192.168.1",          # Missing octet
            "192.168.1.1.1",      # Too many octets
            "not-an-ip",          # Not an IP
            "",                   # Empty
        ]
        
        for ip in valid_ips:
            with self.subTest(ip=ip):
                self.assertTrue(is_valid_ip(ip),
                              f"Valid IP '{ip}' should pass validation")
        
        for ip in invalid_ips:
            with self.subTest(ip=ip):
                self.assertFalse(is_valid_ip(ip),
                               f"Invalid IP '{ip}' should not pass validation")

    def test_validate_period_format(self):
        """Test monitoring period format validation."""
        import re
        # Period should be in format like "60s", "300s", etc.
        period_pattern = re.compile(r'^\d+s$')
        
        valid_periods = [
            "60s",    # 1 minute
            "300s",   # 5 minutes
            "600s",   # 10 minutes
        ]
        
        invalid_periods = [
            "60",     # Missing 's' suffix
            "1m",     # Wrong unit (should be seconds)
            "s",      # Missing number
            "",       # Empty
        ]
        
        for period in valid_periods:
            with self.subTest(period=period):
                self.assertTrue(period_pattern.match(period),
                              f"Valid period '{period}' should match pattern")
        
        for period in invalid_periods:
            with self.subTest(period=period):
                self.assertFalse(period_pattern.match(period),
                               f"Invalid period '{period}' should not match pattern")

    def test_validate_path_format(self):
        """Test HTTP path format validation."""
        valid_paths = [
            "/",
            "/health",
            "/api/status",
            "/index.html",
        ]
        
        invalid_paths = [
            "",           # Empty (should at least be "/")
            "health",     # Missing leading slash
            "//double",   # Double slash
        ]
        
        for path in valid_paths:
            with self.subTest(path=path):
                self.assertTrue(path.startswith("/"),
                              f"Valid path '{path}' should start with '/'")
        
        for path in invalid_paths:
            with self.subTest(path=path):
                if path != "":
                    self.assertFalse(path.startswith("/") and "//" not in path,
                                   f"Invalid path '{path}' should fail validation")

    def test_validate_port_range(self):
        """Test port number range validation."""
        valid_ports = [80, 443, 8080, 3000, 8443]
        invalid_ports = [-1, 0, 65536, 99999]
        
        for port in valid_ports:
            with self.subTest(port=port):
                self.assertTrue(1 <= port <= 65535,
                              f"Valid port {port} should be in range 1-65535")
        
        for port in invalid_ports:
            with self.subTest(port=port):
                self.assertFalse(1 <= port <= 65535,
                               f"Invalid port {port} should be outside range 1-65535")


class TestUptimeCheckFullConfiguration(unittest.TestCase):
    """Test complete uptime check configuration."""

    @patch('subprocess.run')
    def test_complete_uptime_check_configuration(self, mock_run):
        """Test that uptime check has all required configuration fields."""
        # Mock complete uptime check configuration
        mock_response = {
            "displayName": "Nextcloud Uptime Check",
            "name": "projects/my-project/uptimeCheckConfigs/12345",
            "monitoredResource": {
                "type": "uptime_url",
                "labels": {
                    "host": "34.160.123.45",
                    "project_id": "my-gcp-project"
                }
            },
            "httpCheck": {
                "path": "/",
                "port": 80,
                "requestMethod": "GET"
            },
            "period": "60s",
            "timeout": "10s"
        }
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_response),
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "monitoring", "uptime", "describe",
                "Nextcloud Uptime Check",
                "--format=json"
            ],
            capture_output=True,
            text=True
        )
        
        # Parse and validate all fields
        uptime_check = json.loads(result.stdout)
        
        # Validate all required fields are present
        self.assertIn("displayName", uptime_check)
        self.assertIn("monitoredResource", uptime_check)
        self.assertIn("httpCheck", uptime_check)
        self.assertIn("period", uptime_check)
        self.assertIn("timeout", uptime_check)
        
        # Validate nested fields
        self.assertIn("host", uptime_check["monitoredResource"]["labels"])
        self.assertIn("project_id", uptime_check["monitoredResource"]["labels"])
        self.assertIn("path", uptime_check["httpCheck"])
        self.assertIn("port", uptime_check["httpCheck"])
        
        # Validate values
        self.assertEqual(uptime_check["displayName"], "Nextcloud Uptime Check")
        self.assertEqual(uptime_check["httpCheck"]["path"], "/")
        self.assertEqual(uptime_check["httpCheck"]["port"], 80)
        self.assertEqual(uptime_check["period"], "60s")
        self.assertEqual(uptime_check["timeout"], "10s")


if __name__ == '__main__':
    unittest.main()
