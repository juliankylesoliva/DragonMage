using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class Room : MonoBehaviour
{
    [SerializeField] CinemachineConfiner confinedVirtualCamera;

    [SerializeField] PolygonCollider2D cameraBounds;
    public PolygonCollider2D CameraBounds { get { return cameraBounds; } }

    [SerializeField] Transform[] roomEntrances;

    [SerializeField] EnemyBehavior[] enemyList;

    public Vector2 GetRoomEntranceCoordinates(int i)
    {
        if (i >= 0 && i < roomEntrances.Length)
        {
            return new Vector2(roomEntrances[i].position.x, roomEntrances[i].position.y);
        }
        return new Vector2(roomEntrances[0].position.x, roomEntrances[0].position.y);
    }

    public void ActivateRoom()
    {
        this.gameObject.SetActive(true);
        confinedVirtualCamera.m_BoundingShape2D = cameraBounds;
        ActivateEnemies();
    }

    public void DeactivateRoom()
    {
        this.gameObject.SetActive(false);
    }

    private void ActivateEnemies()
    {
        foreach (EnemyBehavior e in enemyList)
        {
            if (!e.isDefeated)
            {
                e.ActivateEnemy();
            }
        }
    }
}
