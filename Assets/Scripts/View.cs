using UnityEngine;

namespace DefaultNamespace
{
    public class View : MonoBehaviour
    {
        public float moveSpeed = 10f;
        public float runSpeed = 20f;
        public float rotateSpeed = 125f;
        private float _speed;
        private float _cinemachineTargetYaw;
        private float _cinemachineTargetPitch;

        void Start()
        {
            ResetYaw();
        }

        public void ResetYaw()
        {
            _cinemachineTargetYaw = transform.rotation.eulerAngles.y;
            _cinemachineTargetPitch = 0;
        }

        // Update is called once per frame
        private void Update()
        {
            FirstPersonMove();
        }

        private void LateUpdate()
        {
            FirstPersonRotate();
        }


        private static float ClampAngle(float lfAngle, float lfMin, float lfMax)
        {
            if (lfAngle < -360f) lfAngle += 360f;
            if (lfAngle > 360f) lfAngle -= 360f;
            return Mathf.Clamp(lfAngle, lfMin, lfMax);
        }

        private void FirstPersonRotate()
        {
            if (Input.GetMouseButton(0))
            {
                float mouseX = Input.GetAxis("Mouse X");
                float mouseY = Input.GetAxis("Mouse Y");
                Vector2 look = new Vector2(mouseX, -mouseY);
                if (look.sqrMagnitude >= 0.01f)
                {
                    _cinemachineTargetYaw += look.x * Time.deltaTime * rotateSpeed;
                    _cinemachineTargetPitch += look.y * Time.deltaTime * rotateSpeed;
                }

                // 夹紧旋转，使我们的值限制为360度 
                _cinemachineTargetYaw = ClampAngle(_cinemachineTargetYaw, float.MinValue, float.MaxValue);
                _cinemachineTargetPitch = ClampAngle(_cinemachineTargetPitch, float.MinValue, float.MaxValue);

                // 修正虚拟摄像机旋转
                transform.rotation = Quaternion.Euler(_cinemachineTargetPitch, _cinemachineTargetYaw, 0.0f);
            }
        }

        private void FirstPersonMove()
        {
            if (Input.GetKey(KeyCode.LeftShift))
            {
                _speed = runSpeed;
            }
            else
            {
                _speed = moveSpeed;
            }

            if (Input.GetKeyDown(KeyCode.PageDown))
            {
                rotateSpeed -= 10;
                Debug.Log(rotateSpeed);
            }

            if (Input.GetKeyDown(KeyCode.PageUp))
            {
                rotateSpeed += 10;
                Debug.Log(rotateSpeed);
            }


            if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.UpArrow))
            {
                transform.Translate(Vector3.forward * Time.deltaTime * _speed, Space.Self);
            }

            if (Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow))
            {
                transform.Translate(Vector3.back * Time.deltaTime * _speed, Space.Self);
            }

            if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.LeftArrow))
            {
                transform.Translate(Vector3.left * Time.deltaTime * _speed, Space.Self);
            }

            if (Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.RightArrow))
            {
                transform.Translate(Vector3.right * Time.deltaTime * _speed, Space.Self);
            }
        }
    }
}