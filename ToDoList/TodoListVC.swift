import UIKit

class TodoListVC: UITableViewController  {

    let itemArray=["A","B","C"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

//MARK: - UITableViewDataSources
extension TodoListVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemList = itemArray[indexPath.row]
        
//        let cell=tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        let cell=UITableViewCell(style: .default , reuseIdentifier: "ToDoItemCell")
        
        cell.textLabel?.text=itemList
        return cell
        
    }
    
}

//MARK: - UITableViewDelegate
extension TodoListVC{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

