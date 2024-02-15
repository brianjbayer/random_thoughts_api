import { check } from 'k6';
import http from 'k6/http';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

export const options = {
  stages: [
    { duration: '1m', target: 100 },
    { duration: '30s', target: 150 },
    // Timeouts start around 170ish VUs
    // { duration: '30s', target: 175 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {
  const create_user_url = `${__ENV.APP_BASE_URL}/v1/users/`;
  const payload = JSON.stringify({
    user: {
      email: `${uuidv4()}@test.org`,
      display_name: `perf test`,
      password: '12345678',
      password_confirmation: '12345678',
    }
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const res = http.post(create_user_url, payload, params);

  check(res, {
    'is status 201': (r) => r.status === 201,
  });
}
