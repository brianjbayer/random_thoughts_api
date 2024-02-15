import { check } from 'k6';
import http from 'k6/http';

export const options = {
  stages: [
    { duration: '1m', target: 100 },
    { duration: '1m', target: 200 },
    { duration: '1m', target: 400 },
    { duration: '1m', target: 800 },
    { duration: '1m', target: 900 },
    { duration: '1m', target: 1000 },
    { duration: '1m', target: 1050 },
    // Timeouts start between 1050 - 1065
    // { duration: '1m', target: 1065 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {
  const res = http.get(`${__ENV.APP_BASE_URL}/v1/random_thoughts/`);
  check(res, {
    'is status 200': (r) => r.status === 200,
  });
}
