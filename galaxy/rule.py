import logging
log = logging.getLogger(__name__)

def rule(tool_id, user_email, resource_params):
    destination_id = 'pulsar'
    if tool_id in ('upload1', '__DATA_FETCH__'):
        destination_id = 'local'
    elif user_email == 'local@example.org':
        destination_id = 'local'
        log.debug(f'User {user_email} force mapped to {destination_id}')
    elif user_email == 'pulsar@example.org':
        destination_id = 'pulsar'
        log.debug(f'User {user_email} force mapped to {destination_id}')
    override = resource_params.get('force_dest')
    if override:
        destination_id = override
        log.debug(f'Override dest selected: {destination_id}')
    else:
        log.debug(f'Default dest for tool selected: {destination_id}')
    return destination_id
