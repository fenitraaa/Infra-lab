import pytest
from unittest.mock import patch, MagicMock, mock_open
import config_server 

@patch("config_server.pwd.getpwnam")
def test_name_exist_true(mock_getpwnam):
    mock_getpwnam.return_value = MagicMock(pw_name="fenitra")
    assert config_server.name_exist("fenitra") == True

@patch("config_server.pwd.getpwnam")
def test_name_exist_false(mock_getpwnam):
    mock_getpwnam.side_effect = KeyError 
    assert config_server.name_exist("fenitra") == False

@patch("config_server.grp.getgrnam")
def test_group_exist_true(mock_getgrnam):
    mock_getgrnam.return_value = MagicMock(gr_name="devops")
    assert config_server.group_exist("devops") == True

@patch("config_server.grp.getgrnam")
def test_group_exist_false(mock_getgrnam):
    mock_getgrnam.side_effect = KeyError
    assert config_server.group_exist("devops") == False

@patch("config_server.os.path.exists")
@patch("builtins.open", mock_open(read_data='{"users": []}'))
def test_load_config_ok(mock_exists):
    mock_exists.return_value = True 
    result = config_server.load_config()
    assert result == {"users": []}

@patch("config_server.os.path.exists")
def test_load_config_file_not_found(mock_exists):
    mock_exists.return_value = False
    with pytest.raises(SystemExit):
        config_server.load_config()

@patch("config_server.run_command")
@patch("config_server.name_exist")
def test_disable_user_vagrant(mock_name_exist, mock_run_command):
    mock_name_exist.return_value = True
    config_server.disable_user_vagrant()
    mock_run_command.assert_called_once_with("usermod -L vagrant")

