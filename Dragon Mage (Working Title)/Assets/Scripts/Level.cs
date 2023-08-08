using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Level : MonoBehaviour
{
    [SerializeField] GameObject playerReference;
    [SerializeField] Room startingRoom;
    [SerializeField] int startingRoomEntranceIndex = 0;
    [SerializeField] Room[] roomList;
    [SerializeField] int fragmentsNeededForMedal = 0;

    private static int _fragmentsNeededForMedal = 0;
    public static int FragmentsNeededForMedal { get { return _fragmentsNeededForMedal; } }

    public static bool isLevelComplete { get; private set; }

    void Awake()
    {
        _fragmentsNeededForMedal = fragmentsNeededForMedal;
        isLevelComplete = false;
    }

    void Start()
    {
        LevelStartup();
    }

    public void SetLevelCompleteFlag()
    {
        isLevelComplete = true;
    }

    private void LevelStartup()
    {
        MedalFragment.ResetFragments();

        Vector2 destinationCoords = startingRoom.GetRoomEntranceCoordinates(startingRoomEntranceIndex);
        playerReference.transform.position = new Vector3(destinationCoords.x, destinationCoords.y, 0f);

        startingRoom.ActivateRoom();
        foreach (Room r in roomList)
        {
            if (r != startingRoom) { r.DeactivateRoom(); }
        }
    }
}
