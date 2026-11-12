import pytest
from fastapi.testclient import TestClient
from app.main import app
client = TestClient(app)

def test_health_is_independent_of_sample_failure():
    assert client.get('/api/sample/orders?scenario=bad-config').status_code == 503
    assert client.get('/health').json()['status'] == 'healthy'

@pytest.mark.parametrize('scenario,status,fragment', [
 ('healthy',200,'No failure'), ('bad-config',503,'Configuration failure'),
 ('dependency-down',503,'underlying cause unconfirmed'),
 ('release-regression',500,'suspected'), ('unknown',500,'Insufficient evidence')])
def test_scenario_contract(scenario,status,fragment):
    assert client.get('/api/sample/orders',params={'scenario':scenario}).status_code == status
    result=client.post('/api/investigate',json={'scenario':scenario})
    assert result.status_code == 200
    data=result.json()
    assert fragment in data['finding']
    assert set(data['evidence_refs']) <= {e['id'] for e in data['evidence']}
    assert data['recovery_executed'] is False
    assert data['data_source'] == 'synthetic'
    if data['runbook']:
        assert client.get(data['runbook']).status_code == 200

@pytest.mark.parametrize('payload',[{}, {'scenario':'invalid'}, {'scenario':42}])
def test_invalid_investigation(payload):
    assert client.post('/api/investigate',json=payload).status_code == 422

def test_invalid_sample():
    assert client.get('/api/sample/orders?scenario=invalid').status_code == 422

def test_runbook_allowlist():
    assert client.get('/api/runbooks/README.md').status_code == 404

def test_home():
    response=client.get('/')
    assert response.status_code == 200
    assert 'text/html' in response.headers['content-type']
    assert 'Rule-based baseline' in response.text

def test_ids_are_unique_and_no_state_leaks():
    first=client.post('/api/investigate',json={'scenario':'bad-config'}).json()
    second=client.post('/api/investigate',json={'scenario':'healthy'}).json()
    assert first['investigation_id'] != second['investigation_id']
    assert second['finding'] == 'No failure observed'
