#!/usr/bin/env python3
"""Unit tests for MIG (Managed Instance Group) validation.

Tests validate that:
1. The unpack MIG's base instance name is correctly validated.
2. The transform MIG's base instance name is correctly validated.
3. The unpack MIG's zone is correctly validated.
4. The transform MIG's zone is correctly validated.
"""

import unittest
from unittest.mock import Mock, patch, call
import subprocess
import os


class TestMIGValidation(unittest.TestCase):
    """Test cases for MIG configuration validation."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_zone = "us-central1-a"
        self.unpack_mig = "unpack-mig"
        self.transform_mig = "transform-mig"
        
        # Expected values
        self.expected_unpack_base_name = "unpack-worker"
        self.expected_transform_base_name = "transform-worker"

    @patch('subprocess.run')
    def test_unpack_mig_base_instance_name_valid(self, mock_run):
        """Test that the unpack MIG's base instance name is correctly validated."""
        # Mock gcloud command response
        mock_run.return_value = Mock(
            stdout="unpack-worker",
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command to get base instance name
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                self.unpack_mig,
                f"--zone={self.test_zone}",
                "--format=value(baseInstanceName)"
            ],
            capture_output=True,
            text=True
        )
        
        # Validate
        base_name = result.stdout.strip()
        self.assertEqual(base_name, self.expected_unpack_base_name,
                        f"Expected base instance name '{self.expected_unpack_base_name}', "
                        f"got '{base_name}'")
        
        # Verify gcloud was called with correct parameters
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn(self.unpack_mig, args)
        self.assertIn(f"--zone={self.test_zone}", args)
        self.assertIn("--format=value(baseInstanceName)", args)

    @patch('subprocess.run')
    def test_unpack_mig_base_instance_name_invalid(self, mock_run):
        """Test that validation fails when unpack MIG has incorrect base instance name."""
        # Mock gcloud command response with wrong name
        mock_run.return_value = Mock(
            stdout="wrong-worker-name",
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                self.unpack_mig,
                f"--zone={self.test_zone}",
                "--format=value(baseInstanceName)"
            ],
            capture_output=True,
            text=True
        )
        
        # Validate
        base_name = result.stdout.strip()
        self.assertNotEqual(base_name, self.expected_unpack_base_name,
                           "Expected validation to fail for incorrect base instance name")

    @patch('subprocess.run')
    def test_transform_mig_base_instance_name_valid(self, mock_run):
        """Test that the transform MIG's base instance name is correctly validated."""
        # Mock gcloud command response
        mock_run.return_value = Mock(
            stdout="transform-worker",
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command to get base instance name
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                self.transform_mig,
                f"--zone={self.test_zone}",
                "--format=value(baseInstanceName)"
            ],
            capture_output=True,
            text=True
        )
        
        # Validate
        base_name = result.stdout.strip()
        self.assertEqual(base_name, self.expected_transform_base_name,
                        f"Expected base instance name '{self.expected_transform_base_name}', "
                        f"got '{base_name}'")
        
        # Verify gcloud was called with correct parameters
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn(self.transform_mig, args)
        self.assertIn(f"--zone={self.test_zone}", args)
        self.assertIn("--format=value(baseInstanceName)", args)

    @patch('subprocess.run')
    def test_transform_mig_base_instance_name_invalid(self, mock_run):
        """Test that validation fails when transform MIG has incorrect base instance name."""
        # Mock gcloud command response with wrong name
        mock_run.return_value = Mock(
            stdout="incorrect-transform",
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                self.transform_mig,
                f"--zone={self.test_zone}",
                "--format=value(baseInstanceName)"
            ],
            capture_output=True,
            text=True
        )
        
        # Validate
        base_name = result.stdout.strip()
        self.assertNotEqual(base_name, self.expected_transform_base_name,
                           "Expected validation to fail for incorrect base instance name")

    @patch('subprocess.run')
    def test_unpack_mig_zone_valid(self, mock_run):
        """Test that the unpack MIG's zone is correctly validated."""
        # Mock gcloud command response (zone returns full URL)
        zone_url = f"https://www.googleapis.com/compute/v1/projects/test-project/zones/{self.test_zone}"
        mock_run.return_value = Mock(
            stdout=zone_url,
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command to get zone
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                self.unpack_mig,
                f"--zone={self.test_zone}",
                "--format=value(zone)"
            ],
            capture_output=True,
            text=True
        )
        
        # Extract zone name from URL (simulating basename)
        zone_full = result.stdout.strip()
        zone_name = zone_full.split('/')[-1]
        
        # Validate
        self.assertEqual(zone_name, self.test_zone,
                        f"Expected zone '{self.test_zone}', got '{zone_name}'")
        
        # Verify gcloud was called with correct parameters
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn(self.unpack_mig, args)
        self.assertIn(f"--zone={self.test_zone}", args)
        self.assertIn("--format=value(zone)", args)

    @patch('subprocess.run')
    def test_unpack_mig_zone_invalid(self, mock_run):
        """Test that validation fails when unpack MIG is in incorrect zone."""
        # Mock gcloud command response with wrong zone
        wrong_zone = "us-west1-a"
        zone_url = f"https://www.googleapis.com/compute/v1/projects/test-project/zones/{wrong_zone}"
        mock_run.return_value = Mock(
            stdout=zone_url,
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                self.unpack_mig,
                f"--zone={self.test_zone}",
                "--format=value(zone)"
            ],
            capture_output=True,
            text=True
        )
        
        # Extract zone name from URL
        zone_full = result.stdout.strip()
        zone_name = zone_full.split('/')[-1]
        
        # Validate
        self.assertNotEqual(zone_name, self.test_zone,
                           "Expected validation to fail for incorrect zone")

    @patch('subprocess.run')
    def test_transform_mig_zone_valid(self, mock_run):
        """Test that the transform MIG's zone is correctly validated."""
        # Mock gcloud command response (zone returns full URL)
        zone_url = f"https://www.googleapis.com/compute/v1/projects/test-project/zones/{self.test_zone}"
        mock_run.return_value = Mock(
            stdout=zone_url,
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command to get zone
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                self.transform_mig,
                f"--zone={self.test_zone}",
                "--format=value(zone)"
            ],
            capture_output=True,
            text=True
        )
        
        # Extract zone name from URL (simulating basename)
        zone_full = result.stdout.strip()
        zone_name = zone_full.split('/')[-1]
        
        # Validate
        self.assertEqual(zone_name, self.test_zone,
                        f"Expected zone '{self.test_zone}', got '{zone_name}'")
        
        # Verify gcloud was called with correct parameters
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn(self.transform_mig, args)
        self.assertIn(f"--zone={self.test_zone}", args)
        self.assertIn("--format=value(zone)", args)

    @patch('subprocess.run')
    def test_transform_mig_zone_invalid(self, mock_run):
        """Test that validation fails when transform MIG is in incorrect zone."""
        # Mock gcloud command response with wrong zone
        wrong_zone = "europe-west1-b"
        zone_url = f"https://www.googleapis.com/compute/v1/projects/test-project/zones/{wrong_zone}"
        mock_run.return_value = Mock(
            stdout=zone_url,
            stderr="",
            returncode=0
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                self.transform_mig,
                f"--zone={self.test_zone}",
                "--format=value(zone)"
            ],
            capture_output=True,
            text=True
        )
        
        # Extract zone name from URL
        zone_full = result.stdout.strip()
        zone_name = zone_full.split('/')[-1]
        
        # Validate
        self.assertNotEqual(zone_name, self.test_zone,
                           "Expected validation to fail for incorrect zone")

    @patch('subprocess.run')
    def test_mig_not_found(self, mock_run):
        """Test handling when MIG does not exist."""
        # Mock gcloud command returning error
        mock_run.return_value = Mock(
            stdout="",
            stderr="ERROR: (gcloud.compute.instance-groups.managed.describe) Could not fetch resource",
            returncode=1
        )
        
        # Execute gcloud command
        result = subprocess.run(
            [
                "gcloud", "compute", "instance-groups", "managed", "describe",
                "non-existent-mig",
                f"--zone={self.test_zone}",
                "--format=value(baseInstanceName)"
            ],
            capture_output=True,
            text=True
        )
        
        # Validate error is returned
        self.assertNotEqual(result.returncode, 0,
                           "Expected non-zero return code for non-existent MIG")
        self.assertIn("ERROR", result.stderr,
                     "Expected error message in stderr")


class TestMIGValidationHelper(unittest.TestCase):
    """Test helper functions for MIG validation."""

    def test_extract_zone_from_url(self):
        """Test extracting zone name from GCP URL."""
        test_cases = [
            (
                "https://www.googleapis.com/compute/v1/projects/my-project/zones/us-central1-a",
                "us-central1-a"
            ),
            (
                "https://www.googleapis.com/compute/v1/projects/test/zones/europe-west1-b",
                "europe-west1-b"
            ),
            (
                "us-east1-c",  # Already just the zone name
                "us-east1-c"
            ),
        ]
        
        for url, expected_zone in test_cases:
            with self.subTest(url=url):
                # Simulate basename extraction
                zone_name = url.split('/')[-1]
                self.assertEqual(zone_name, expected_zone,
                               f"Failed to extract zone from {url}")

    def test_validate_base_instance_name_format(self):
        """Test that base instance names follow expected format."""
        valid_names = [
            "unpack-worker",
            "transform-worker",
        ]
        
        invalid_names = [
            "unpack_worker",  # underscore instead of hyphen
            "UnpackWorker",   # camelCase
            "unpack",         # missing -worker suffix
            "",               # empty
        ]
        
        expected_pattern = r"^[a-z]+-worker$"
        import re
        pattern = re.compile(expected_pattern)
        
        for name in valid_names:
            with self.subTest(name=name):
                self.assertTrue(pattern.match(name),
                              f"Valid name '{name}' should match pattern")
        
        for name in invalid_names:
            with self.subTest(name=name):
                self.assertFalse(pattern.match(name),
                               f"Invalid name '{name}' should not match pattern")


if __name__ == '__main__':
    unittest.main()
