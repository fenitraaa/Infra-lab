import pytest
from unittest.mock import patch, MagicMock
import config_pki
import hvac


@patch("config_pki.hvac.Client")
def test_login_success(mock_client):
    mock_instance = MagicMock()
    mock_instance.is_authenticated.return_value = True
    mock_client.return_value = mock_instance
    assert config_pki.login() == mock_instance

@patch("config_pki.hvac.Client")
def test_login_failed(mock_client):
    mock_instance = MagicMock()
    mock_instance.is_authenticated.return_value = False
    mock_client.return_value = mock_instance    
    with pytest.raises(PermissionError):
        config_pki.login()

@patch("config_pki.subprocess.run")
def test_server_actif_true(mock_run):
    mock_run.return_value = MagicMock(returncode=0)
    assert config_pki.server_actif("db") == True

@patch("config_pki.subprocess.run")
def test_server_actif_false(mock_run):
    mock_run.return_value = MagicMock(returncode=1)
    assert config_pki.server_actif("db") == False

def test_enable_pki_mode_enables_engine():
    mock_client = MagicMock()
    config_pki.enable_pki_mode(mock_client)

    mock_client.sys.enable_secrets_engine.assert_called_once_with(
        backend_type="pki",
        path="pki"
    )

def test_enable_pki_mode_tunes_ttl():
    mock_client = MagicMock()
    config_pki.enable_pki_mode(mock_client)

    mock_client.sys.tune_mount_configuration.assert_called_once_with(
        path="pki",
        max_lease_ttl="87600h"
    )
def test_enable_pki_mode_already_mounted():
    mock_client = MagicMock()
    mock_client.sys.enable_secrets_engine.side_effect = hvac.exceptions.InvalidRequest(
        "path is already in use"
    )
    config_pki.enable_pki_mode(mock_client)
