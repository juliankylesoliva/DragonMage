using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    [SerializeField] Vector3 cameraOffset;
    [SerializeField] float parallaxFactorX = 0.01f;
    [SerializeField] float parallaxFactorY = 0.5f;

    private Vector3 baselinePosition;

    void Start()
    {
        baselinePosition = Camera.main.transform.position;
    }

    void LateUpdate()
    {
        Vector3 parallaxDelta = (baselinePosition - Camera.main.transform.position);
        parallaxDelta.z = 0f;
        parallaxDelta.x *= parallaxFactorX;
        parallaxDelta.y *= parallaxFactorY;

        this.transform.position = (Camera.main.transform.position + parallaxDelta + cameraOffset);
    }
}
